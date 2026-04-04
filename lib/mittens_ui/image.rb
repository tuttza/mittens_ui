# frozen_string_literal: true
require 'mittens_ui/core'

module MittensUi
  # An image widget that displays a static image or animated GIF.
  # Wraps {https://docs.gtk.org/gtk4/class.Image.html Gtk::Image}.
  # Click events are handled via {https://docs.gtk.org/gtk4/class.GestureClick.html Gtk::GestureClick}.
  #
  # @example Basic image
  #   img = MittensUi::Image.new('./assets/logo.png', width: 200, height: 200)
  #
  # @example With click handler
  #   img = MittensUi::Image.new('./assets/logo.png')
  #   img.click { puts 'image clicked!' }
  #
  # @example Animated GIF
  #   img = MittensUi::Image.new('./assets/animation.gif')
  class Image < Core
    attr_reader :path

    # Creates a new Image widget.
    #
    # @param path [String] path to the image file
    # @param options [Hash] configuration options
    # @option options [String] :tooltip_text ('') tooltip shown on hover
    # @option options [Integer] :width (80) image width in pixels
    # @option options [Integer] :height (80) image height in pixels
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(path, options = {})
      @path        = path.strip
      tooltip_text = options[:tooltip_text] || ''
      @img_width   = options[:width]        || 80
      @img_height  = options[:height]       || 80

      if @path.include?('.gif')
        init_gif
      else
        init_static_image
      end

      @image.tooltip_text = tooltip_text

      # GTK4: use a Picture widget for better size control if available,
      # otherwise wrap in a fixed-size container
      @container = Gtk::Box.new(:vertical, 0)
      @container.set_size_request(@img_width, @img_height)
      @container.halign = :start
      @container.valign = :start
      @container.append(@image)

      super(@container, options)
    end

    # Connects a block to the click event.
    #
    # @yield called when the image is clicked
    # @return [void]
    # @example
    #   img.click { puts 'clicked!' }
    def click
      gesture = Gtk::GestureClick.new
      gesture.signal_connect('pressed') { yield }
      @container.add_controller(gesture)
    end

    private

    # Initializes a static image scaled to the requested dimensions.
    # Uses GdkPixbuf to scale and then wraps in Gtk::Picture for GTK4
    # accurate size rendering.
    #
    # @return [void]
    def init_static_image
      pixbuf = GdkPixbuf::Pixbuf.new(file: @path)
      scaled = pixbuf.scale_simple(
        @img_width,
        @img_height,
        GdkPixbuf::InterpType::BILINEAR
      )
      # GTK4: Gtk::Picture respects exact pixbuf dimensions better than Gtk::Image
      @image = Gtk::Picture.new
      @image.set_pixbuf(scaled)
      @image.set_size_request(@img_width, @img_height)
      @image.content_fit = :fill
      @image.halign = :start
      @image.valign = :start
    end

    # Initializes an animated GIF image.
    #
    # @return [void]
    def init_gif
      pixbuf = GdkPixbuf::PixbufAnimation.new(@path)
      @image = Gtk::Image.new(animation: pixbuf)
      @image.set_size_request(@img_width, @img_height)
    end
  end
end
