require_relative "./core"

module MittensUi
  # A color picker dialog that allows the user to select a color.
  # Wraps {https://docs.gtk.org/gtk3/class.ColorChooserDialog.html Gtk::ColorChooserDialog}.
  # When instantiated, the dialog opens immediately and blocks until the user
  # selects a color or cancels. The selected color is accessible via {#hex},
  # {#rgb}, and {#rgba} after the dialog closes.
  #
  # @example Basic usage
  #   picker = MittensUi::ColorPicker.new
  #   puts picker.hex   # => "#ff0000"
  #   puts picker.rgb   # => [255, 0, 0]
  #   puts picker.rgba  # => [255, 0, 0, 255]
  #
  # @example With a default color
  #   picker = MittensUi::ColorPicker.new(default: "#336699")
  #   puts picker.hex   # => "#336699" if user cancels
  #
  # @example With alpha channel
  #   picker = MittensUi::ColorPicker.new(alpha: true)
  #   puts picker.rgba  # => [255, 0, 0, 128]
  #
  # @example Reacting to selection
  #   picker = MittensUi::ColorPicker.new
  #   if picker.selected?
  #     puts "User picked: #{picker.hex}"
  #   else
  #     puts "User cancelled"
  #   end
  class ColorPicker

    # @return [Boolean] whether the user selected a color (vs cancelling)
    attr_reader :selected

    # Creates a new ColorPicker dialog and opens it immediately.
    #
    # @param options [Hash] configuration options
    # @option options [String] :title ("Pick a Color") the dialog title
    # @option options [String] :default (nil) a hex color string to pre-select
    #   e.g. "#ff0000". If nil, defaults to black.
    # @option options [Boolean] :alpha (false) when true, shows an alpha
    #   channel slider allowing the user to pick transparency
    def initialize(options = {})
      @title    = options[:title]   || 'Pick a Color'
      @default  = options[:default] || nil
      @alpha    = options[:alpha]   || false
      @selected = false
      @color    = nil

      open_dialog
    end

    # Returns whether the user selected a color.
    # Returns false if the user cancelled the dialog.
    #
    # @return [Boolean]
    def selected?
      @selected
    end

    # Returns the selected color as a hex string.
    # Returns the default color if the user cancelled, or "#000000" if no default was set.
    #
    # @return [String] hex color string e.g. "#ff0000"
    # @example
    #   picker.hex  # => "#ff0000"
    def hex
      return @default || "#000000" unless @selected && @color
      r, g, b = rgb
      "#%02x%02x%02x" % [r, g, b]
    end

    # Returns the selected color as an RGB array.
    # Values are in the range 0-255.
    #
    # @return [Array<Integer>] [red, green, blue]
    # @example
    #   picker.rgb  # => [255, 0, 0]
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
    # @example
    #   picker.rgba  # => [255, 0, 0, 255]
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

    # Opens the color chooser dialog, sets the default color if provided,
    # and stores the result when the user confirms or cancels.
    #
    # @return [void]
    def open_dialog
      parent = MittensUi::Application.window
      dialog = Gtk::ColorChooserDialog.new(title: @title, parent: parent)
      dialog.use_alpha = @alpha

      if @default
        rgba = Gdk::RGBA.new
        rgba.parse(@default)
        dialog.rgba = rgba
      end

      if dialog.run == Gtk::ResponseType::OK
        @color    = dialog.rgba
        @selected = true
      end

      dialog.destroy
    end
  end
end
