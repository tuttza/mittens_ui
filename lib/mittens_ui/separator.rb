require_relative "./core"

module MittensUi
  # A visual divider used to separate sections of a UI.
  # Wraps {https://docs.gtk.org/gtk3/class.Separator.html Gtk::Separator}.
  # Vertical separators are automatically wrapped in a horizontal Gtk::Box
  # with a minimum height so they render correctly in any layout context.
  #
  # @example Horizontal separator (default)
  #   MittensUi::Separator.new
  #
  # @example Vertical separator
  #   MittensUi::Separator.new(:vertical)
  #
  # @example With margin
  #   MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)
  class Separator < Core

    # Creates a new Separator widget.
    #
    # @param orientation [Symbol] the orientation of the separator.
    #   Accepted values are +:horizontal+ (default) and +:vertical+
    # @param options [Hash] configuration options
    # @option options [Integer] :height (50) height of the container in pixels.
    #   Only applies to +:vertical+ orientation.
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Integer] :top top margin in pixels
    # @option options [Integer] :bottom bottom margin in pixels
    # @option options [Integer] :left left margin in pixels
    # @option options [Integer] :right right margin in pixels
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(orientation = :horizontal, options = {})
      unless %i[horizontal vertical].include?(orientation)
        raise ArgumentError, "orientation must be :horizontal or :vertical"
      end

      @separator = Gtk::Separator.new(orientation)

      widget = if orientation == :vertical
        height = options[:height] || 100
        container = Gtk::Box.new(:horizontal, 0)
        container.set_size_request(10, height)
        @separator.set_size_request(2, height)
        container.pack_start(@separator, expand: true, fill: true, padding: 1)
        container
      else
        @separator
      end

      super(widget, options)
    end
  end
end