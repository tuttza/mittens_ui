# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A header bar widget that replaces the window title bar.
  # Wraps {https://docs.gtk.org/gtk4/class.HeaderBar.html Gtk::HeaderBar}.
  # Widgets passed in are placed on the left or right side of the header bar.
  #
  # @example Left-aligned buttons
  #   add_btn = MittensUi::Button.new(title: "Add", defer_render: true)
  #   MittensUi::HeaderBar.new([add_btn], title: "My App", position: :left)
  #
  # @example Right-aligned buttons
  #   MittensUi::HeaderBar.new([btn], title: "My App", position: :right)
  class HeaderBar < Core

    # Creates a new HeaderBar widget.
    #
    # @param widgets [Array<MittensUi::Core>] widgets to place in the header bar.
    #   Each widget must be created with +defer_render: true+.
    # @param options [Hash] configuration options
    # @option options [String] :title ("") the header bar title text
    # @option options [Symbol] :position (:left) placement of widgets.
    #   Accepted values are +:left+ and +:right+
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(widgets, options = {})
      title    = options.fetch(:title, '')
      position = options.fetch(:position, :left)

      @header = Gtk::HeaderBar.new

      @header.show_title_buttons = true

      # use a Gtk::Label as the title widget
      title_label = Gtk::Label.new(title)
      @header.title_widget = title_label

      box = Gtk::Box.new(:horizontal, 0)
      box.add_css_class('linked')

      widgets.each do |w|
        w.remove
        box.append(w.core_widget)
      end

      if position == :right
        @header.pack_end(box)
      else
        @header.pack_start(box)
      end

      super(@header, options)
    end

    # Places the header bar as the window titlebar.
    # Called automatically by {MittensUi::Core#render}.
    #
    # @return [void]
    def render
      MittensUi::Application.window.titlebar = @header
    end
  end
end
