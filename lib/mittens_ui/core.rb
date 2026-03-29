require "mittens_ui/helpers"

module MittensUi
  # Base class for all MittensUi widgets.
  # All components inherit from Core, which handles rendering into the
  # application layout automatically on instantiation.
  #
  # Widgets are rendered into the {MittensUi::LayoutManager} grid using
  # a 12-unit column system. The width of a widget can be controlled via
  # the +:width+ option.
  #
  # @example Creating a custom widget that inherits from Core
  #   class MyWidget < MittensUi::Core
  #     def initialize(options = {})
  #       @gtk_widget = Gtk::Label.new("Hello")
  #       super(@gtk_widget, options)
  #     end
  #   end
  #
  # @example Controlling widget width
  #   MittensUi::Label.new("Half width", width: :half)
  #   MittensUi::Label.new("Full width", width: :full)
  #
  # @example Deferring render for container widgets like HeaderBar
  #   MittensUi::Button.new(title: "Click", defer_render: true)
  class Core
    include Helpers

    # The underlying GTK widget instance.
    # Use this to access raw GTK functionality not exposed by MittensUi.
    #
    # @return [Gtk::Widget] the underlying GTK widget
    attr_reader :core_widget

    # Initializes the widget, sets its width and margins, and renders it
    # into the application layout unless +:defer_render+ is true.
    #
    # @param widget [Gtk::Widget] the underlying GTK widget to wrap
    # @param options [Hash] configuration options
    # @option options [Symbol] :width (:full) the column width of the widget.
    #   Accepted values are +:full+, +:half+, +:third+, +:quarter+
    # @option options [Boolean] :defer_render (false) when true, the widget
    #   will not be automatically added to the layout on initialization.
    #   Use this when passing a widget as a child to a container like {HBox} or {HeaderBar}
    # @option options [Integer] :top top margin in pixels
    # @option options [Integer] :left left margin in pixels
    # @option options [Integer] :bottom bottom margin in pixels
    # @option options [Integer] :right right margin in pixels
    def initialize(widget, options = {})
      @core_widget = widget
      @width = options[:width] || :full
      @defer_render = options[:defer_render] || false
      set_margin_from_opts_for(@core_widget, options)
      render unless @defer_render
    end

    # Shows the widget if it is hidden.
    #
    # @return [void]
    # @example
    #   btn = MittensUi::Button.new(title: "Click")
    #   btn.hide
    #   btn.show
    def show
      @core_widget.show_all
    end

    # Returns whether the widget is currently hidden.
    #
    # @return [Boolean] true if the widget is visible, false if hidden
    # @note This delegates to GTK's +visible?+ method
    # @example
    #   btn.hidden?  # => false
    #   btn.hide
    #   btn.hidden?  # => true
    def hidden?
      @core_widget.visible?
    end

    # Hides the widget from view without removing it from the layout.
    # The widget can be shown again by calling {#show}.
    #
    # @return [void]
    # @example
    #   btn = MittensUi::Button.new(title: "Click")
    #   btn.hide
    def hide
      return if @core_widget.nil?
      @core_widget.hide
    end

    # Removes the widget from the application layout permanently.
    # Unlike {#hide}, this cannot be undone.
    #
    # @return [void]
    # @example
    #   btn = MittensUi::Button.new(title: "Click")
    #   btn.remove
    def remove
      MittensUi::Application.layout.remove(@core_widget)
    end

    # Adds the widget to the application layout grid.
    # Called automatically during initialization unless +:defer_render+ is true.
    # Can be overridden in subclasses that require special placement
    # (e.g. {HeaderBar}, {Notify}).
    #
    # @return [void]
    def render
      MittensUi::Application.layout.add(@core_widget, width: @width)
    end
  end
end