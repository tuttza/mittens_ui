# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A color picker dialog that allows the user to select a color.
  # Wraps {https://docs.gtk.org/gtk4/class.ColorDialog.html Gtk::ColorDialog}.
  # Opens immediately on instantiation using an async API.
  # The selected color is accessible via {#hex}, {#rgb}, and {#rgba}.
  #
  # @example Basic usage
  #   picker = MittensUi::ColorPicker.new
  #   puts picker.hex   # => "#ff0000"
  #   puts picker.rgb   # => [255, 0, 0]
  #   puts picker.rgba  # => [255, 0, 0, 255]
  #
  # @example With a default color
  #   picker = MittensUi::ColorPicker.new(default: "#336699")
  #
  # @example With alpha channel
  #   picker = MittensUi::ColorPicker.new(alpha: true)
  #
  # @example With block — only fires if user selected a color
  #   MittensUi::ColorPicker.new do |color|
  #     puts color.hex
  #   end
  class ColorPicker

    # @return [Boolean] whether the user selected a color
    attr_reader :selected

    # Creates a new ColorPicker dialog and opens it immediately.
    #
    # @param options [Hash] configuration options
    # @option options [String] :title ("Pick a Color") the dialog title
    # @option options [String] :default (nil) a hex color string to pre-select
    # @option options [Boolean] :alpha (false) show alpha channel slider
    # @yield [picker] called only if the user selected a color
    # @yieldparam picker [MittensUi::ColorPicker] the picker with color data
    def initialize(options = {}, &block)
      @title    = options[:title]   || 'Pick a Color'
      @default  = options[:default] || nil
      @alpha    = options[:alpha]   || false
      @selected = false
      @color    = nil

      open_dialog(&block)
    end

    # Returns whether the user selected a color.
    #
    # @return [Boolean]
    def selected?
      @selected
    end

    # Returns the selected color as a hex string.
    # Returns the default or "#000000" if cancelled.
    #
    # @return [String] hex color string e.g. "#ff0000"
    def hex
      return @default || '#000000' unless @selected && @color

      r, g, b = rgb
      "#%02x%02x%02x" % [r, g, b]
    end

    # Returns the selected color as an RGB array.
    # Values are in the range 0-255.
    #
    # @return [Array<Integer>] [red, green, blue]
    def rgb
      return [0, 0, 0] unless @selected && @color

      [
        (@color.red   * 255).round,
        (@color.green * 255).round,
        (@color.blue  * 255).round
      ]
    end

    # Returns the selected color as an RGBA array.
    # Values are in the range 0-255.
    #
    # @return [Array<Integer>] [red, green, blue, alpha]
    def rgba
      return [0, 0, 0, 255] unless @selected && @color

      [
        (@color.red   * 255).round,
        (@color.green * 255).round,
        (@color.blue  * 255).round,
        (@color.alpha * 255).round
      ]
    end

    private

    # Opens the color dialog using Gtk::ColorDialog async API.
    #
    # @return [void]
    def open_dialog(&block)
      parent = MittensUi::Application.window

      dialog = Gtk::ColorDialog.new
      dialog.title     = @title
      dialog.modal     = true
      dialog.with_alpha = @alpha

      # set default color if provided
      initial_color = nil
      if @default
        initial_color = Gdk::RGBA.new
        initial_color.parse(@default)
      end

      dialog.choose_rgba(parent, initial_color, nil) do |_source, result|
        begin
          @color    = dialog.choose_rgba_finish(result)
          @selected = true
          block&.call(self)
        rescue => _e
          # user cancelled or error
          @selected = false
        end
      end
    end
  end
end
