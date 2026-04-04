# frozen_string_literal: true

require 'mittens_ui/core'
require 'mittens_ui/helpers'

module MittensUi
  # A horizontal layout container that places widgets side by side in a row.
  # Wraps {https://docs.gtk.org/gtk4/class.Box.html Gtk::Box} with +:horizontal+ orientation.
  # Supports nesting — HBox instances can be placed inside other HBox instances.
  #
  # @example Block style
  #   MittensUi::HBox.new(spacing: 8) do
  #     MittensUi::Label.new("Name:")
  #     MittensUi::Textbox.new(can_edit: true)
  #   end
  #
  # @example Nested HBox
  #   MittensUi::HBox.new(spacing: 8) do
  #     MittensUi::Label.new("Left")
  #     MittensUi::HBox.new(spacing: 4) do
  #       MittensUi::Button.new(title: "A")
  #       MittensUi::Button.new(title: "B")
  #     end
  #   end
  #
  # @example Array style
  #   MittensUi::HBox.new([
  #     MittensUi::Button.new(title: "OK",     defer_render: true),
  #     MittensUi::Button.new(title: "Cancel", defer_render: true)
  #   ], spacing: 6)
  class HBox < Core
    include Helpers

    # Creates a new HBox container.
    #
    # @param widgets_or_options [Array, Hash] either an array of pre-built widgets
    #   or an options hash when using block style
    # @param options [Hash] configuration options (only used with array style)
    # @option options [Integer] :spacing (6) space in pixels between widgets
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Integer] :top top margin in pixels
    # @option options [Integer] :bottom bottom margin in pixels
    # @option options [Integer] :left left margin in pixels
    # @option options [Integer] :right right margin in pixels
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    # @yield optional block — widgets created inside are automatically added to the row
    def initialize(widgets_or_options = [], options = {}, &block)
      if widgets_or_options.is_a?(Hash)
        options = widgets_or_options
        widgets = []
      else
        widgets = widgets_or_options
      end

      box_spacing = options[:spacing] || 6
      @box = Gtk::Box.new(:horizontal, box_spacing)
      set_margin_from_opts_for(@box, options)

      if block_given?
        MittensUi::Application.push_container(self)
        instance_eval(&block)
        MittensUi::Application.pop_container
      else
        widgets.each do |w|
          w.remove if w.respond_to?(:remove)
          attach(w.core_widget)
        end
      end

      super(@box, options)
    end

    # Attaches a raw GTK widget to the horizontal box.
    # Called automatically by {MittensUi::Core#render} when widgets are
    # created inside an HBox block.
    #
    # @param gtk_widget [Gtk::Widget] the GTK widget to attach
    # @return [void]
    def attach_widget(gtk_widget)
      attach(gtk_widget)
    end

    # Removes the HBox from the application layout.
    #
    # @return [void]
    def remove
      return if @box.nil?

      MittensUi::Application.layout.remove(@box)
    end

    private

    # Packs a GTK widget into the horizontal box.
    #
    # @param widget [Gtk::Widget] the widget to pack
    # @param position [Symbol] +:start+ (default) or +:end+
    # @param expand [Boolean] whether the widget expands to fill available space
    # @param fill [Boolean] whether the widget fills its allocated space
    # @param padding [Integer] padding in pixels around the widget
    # @return [void]
    def attach(widget, position: :start, expand: true, fill: true, padding: 0)
      case position
      when :end
        @box.append(widget)
        widget.hexpand = expand
        widget.vexpand = false
        widget.hexpand_set = true
      else
        @box.prepend(widget)
        widget.hexpand = expand
        widget.vexpand = false
        widget.hexpand_set = true
      end
    end
  end
end
