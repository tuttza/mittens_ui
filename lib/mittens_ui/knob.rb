# frozen_string_literal: true

require 'mittens_ui/core'
require 'mittens_ui/helpers'

module MittensUi
  # A rotary knob widget that mimics the feel of a synthesizer knob.
  # Built on {https://docs.gtk.org/gtk4/class.DrawingArea.html Gtk::DrawingArea}
  # and drawn with Cairo. Click and drag up/right to increase the value,
  # drag down/left to decrease it. Scroll wheel also works.
  #
  # @example Basic knob
  #   knob = MittensUi::Knob.new(min: 0, max: 100, value: 50)
  #   knob.on_change { |v| puts "Value: #{v}" }
  #
  # @example With label and custom size
  #   knob = MittensUi::Knob.new(
  #     min:   0,
  #     max:   127,
  #     value: 64,
  #     size:  80,
  #     label: "Cutoff",
  #     color: [0.2, 0.6, 1.0]
  #   )
  class Knob < Core
    include Helpers

    # Creates a new Knob widget.
    #
    # @param options [Hash] configuration options
    # @option options [Float, Integer] :min (0) minimum value
    # @option options [Float, Integer] :max (100) maximum value
    # @option options [Float, Integer] :value (50) initial value
    # @option options [Integer] :size (60) diameter of the knob in pixels
    # @option options [String, nil] :label (nil) optional label shown below the knob
    # @option options [Array<Float>] :color ([0.2, 0.8, 0.4]) RGB color of the knob
    #   indicator, each value in range 0.0..1.0
    # @option options [Symbol] :width (:quarter) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      @min       = options[:min]   || 0
      @max       = options[:max]   || 100
      @value     = options[:value] || (@min + @max) / 2.0
      @size      = options[:size]  || 60
      @label     = options[:label] || nil
      @color     = options[:color] || [0.2, 0.8, 0.4]
      @on_change = nil
      @dragging  = false
      @last_y    = 0
      @last_x    = 0

      options[:width] ||= :quarter

      @container = build_widget
      super(@container, options)
    end

    # Returns the current value of the knob.
    #
    # @return [Float] the current value
    def value
      @value.round(2)
    end

    # Sets the knob value programmatically.
    # Value is clamped to the min/max range.
    #
    # @param val [Float, Integer] the new value
    # @return [void]
    def value=(val)
      @value = val.clamp(@min.to_f, @max.to_f)
      @drawing_area.queue_draw
      @on_change&.call(value)
    end

    # Connects a block that fires whenever the knob value changes.
    #
    # @yield [value] called when the value changes
    # @yieldparam value [Float] the new value
    # @return [void]
    # @example
    #   knob.on_change { |v| puts "Knob: #{v}" }
    def on_change(&block)
      @on_change = block
    end

    private

    # Builds the drawing area and wires up gesture controllers.
    #
    # @return [Gtk::Box] container holding the drawing area and optional label
    def build_widget
      container = Gtk::Box.new(:vertical, 4)

      @drawing_area = Gtk::DrawingArea.new
      @drawing_area.set_size_request(@size, @size)

      @drawing_area.set_draw_func do |_widget, cr, _width, _height|
        draw_knob(cr)
      end

      drag = Gtk::GestureDrag.new
      drag.signal_connect("drag-begin") do |_gesture, _x, y|
        @dragging = true
        @last_y   = y
        @last_x   = 0
      end

      drag.signal_connect("drag-update") do |_gesture, offset_x, offset_y|
        if @dragging
          delta_y = -offset_y  # negative because dragging up should increase
          delta_x = offset_x
          delta   = (delta_y + delta_x) * sensitivity
          self.value = @value + delta
          @last_y += offset_y
          @last_x += offset_x
        end
      end

      drag.signal_connect("drag-end") do
        @dragging = false
      end

      @drawing_area.add_controller(drag)

      scroll = Gtk::EventControllerScroll.new(:vertical)
      scroll.signal_connect("scroll") do |_controller, _dx, dy|
        self.value = @value - dy * sensitivity * 5
        true
      end

      @drawing_area.add_controller(scroll)

      container.append(@drawing_area)

      if @label
        lbl = Gtk::Label.new(@label)
        container.append(lbl)
      end

      container
    end

    # Returns how much the value changes per pixel of drag movement.
    #
    # @return [Float]
    def sensitivity
      (@max - @min).to_f / 200.0
    end

    # Returns the current value as a normalized 0.0..1.0 float.
    #
    # @return [Float]
    def normalized
      (@value - @min).to_f / (@max - @min).to_f
    end

    # Returns the angle in radians for the knob indicator.
    # The knob travels from -225 degrees (min) to +45 degrees (max),
    # giving a 270 degree range like a real synth knob.
    #
    # @return [Float] angle in radians
    def angle
      start_angle = 225 * (Math::PI / 180.0)
      range_angle = 270 * (Math::PI / 180.0)
      Math::PI / 2.0 + start_angle - (normalized * range_angle)
    end

    # Draws the knob using Cairo.
    #
    # @param cr [Cairo::Context] the Cairo drawing context
    # @return [void]
    def draw_knob(cr)
      cx = @size / 2.0
      cy = @size / 2.0
      r  = (@size / 2.0) - 4

      # background circle
      cr.arc(cx, cy, r, 0, 2 * Math::PI)
      cr.set_source_rgb(0.15, 0.15, 0.15)
      cr.fill

      # track arc (full range)
      start_a = Math::PI / 2.0 + 225 * (Math::PI / 180.0)
      end_a   = Math::PI / 2.0 + 225 * (Math::PI / 180.0) - 270 * (Math::PI / 180.0)
      cr.arc_negative(cx, cy, r - 4, start_a, end_a)
      cr.set_source_rgb(0.3, 0.3, 0.3)
      cr.set_line_width(3)
      cr.stroke

      # value arc (filled portion)
      cr.arc_negative(cx, cy, r - 4, start_a, angle)
      cr.set_source_rgb(*@color)
      cr.set_line_width(3)
      cr.stroke

      # indicator dot
      dot_r = r - 10
      dot_x = cx + dot_r * Math.cos(angle)
      dot_y = cy - dot_r * Math.sin(angle)
      cr.arc(dot_x, dot_y, 3, 0, 2 * Math::PI)
      cr.set_source_rgb(*@color)
      cr.fill

      # outer ring
      cr.arc(cx, cy, r, 0, 2 * Math::PI)
      cr.set_source_rgb(0.4, 0.4, 0.4)
      cr.set_line_width(1.5)
      cr.stroke

      # value text
      cr.set_source_rgb(0.9, 0.9, 0.9)
      cr.set_font_size(9)
      text = value.to_s
      extents = cr.text_extents(text)
      cr.move_to(cx - extents.width / 2, cy + extents.height / 2)
      cr.show_text(text)
    end
  end
end
