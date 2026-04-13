# frozen_string_literal: true

require 'mittens_ui/core'
require 'mittens_ui/helpers'

module MittensUi

  # A clickable button widget with optional icon and loading state support.
  #
  # Wraps {https://docs.gtk.org/gtk3/class.Button.html Gtk::Button}.
  # When in loading state, the button is disabled and a spinner replaces
  # or appears alongside the label to indicate background work is running.
  #
  # @example Basic button
  #   btn = MittensUi::Button.new(title: "Click Me")
  #   btn.click { puts "clicked!" }
  #
  # @example Button with icon
  #   btn = MittensUi::Button.new(title: "Add", icon: :add_green)
  #
  # @example Button with loading state
  #   btn = MittensUi::Button.new(title: "Save")
  #   btn.click do
  #     btn.loading do
  #       sleep 2  # do some work
  #       puts "done!"
  #     end
  #   end
  class Button < Core
    include Helpers

    # Creates a new Button widget.
    #
    # @param options [Hash] configuration options
    # @option options [String] :title ("Button") the button label text
    # @option options [Symbol] :icon (nil) an icon key from the icon map.
    #   When set, an icon is displayed instead of a text label.
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      button_title = options[:title] || 'Button'
      icon_type    = options[:icon]  || nil

      @loading  = false
      @button   = Gtk::Button.new
      @box      = Gtk::Box.new(:horizontal, 4)
      @spinner  = Gtk::Spinner.new

      if icon_type
        image = Gtk::Image.new(icon_name: icon_map[icon_type], size: :button)
        @box.append(image)
      end

      @label = Gtk::Label.new(button_title)
      @box.append(@label)
      @box.set_halign(:center)
      @box.append(@spinner)

      @button.set_child(@box)
      @spinner.hide

      super(@button, options)
    end

    # Enables or disables the button.
    #
    # @param answer [Boolean] true to enable, false to disable
    # @return [void]
    # @example
    #   btn.enable(false)  # disable
    #   btn.enable(true)   # enable
    def enable(answer)
      @button.set_sensitive(answer)
    end

    # Returns whether the button is currently in a loading state.
    #
    # @return [Boolean] true if loading, false otherwise
    def loading?
      @loading
    end

    # Connects a block to the button's click event.
    #
    # @yield [button_widget] the GTK button widget that was clicked
    # @yieldparam button_widget [Gtk::Button] the underlying GTK button
    # @return [void]
    # @example
    #   btn.click do |b|
    #     puts "Button was clicked!"
    #   end
    def click
      @button.signal_connect('clicked') do
        yield(self)
      end
    end

    # Runs a block in a background thread while showing a loading spinner
    # and disabling the button. Re-enables the button when the block finishes.
    # Safe to call from a click handler.
    #
    # @yield the block of work to run in the background
    # @return [void]
    # @example
    #   btn.click do
    #     btn.loading do
    #       sleep 3
    #       puts "Work done!"
    #     end
    #   end
    def loading
      return if @loading

      @loading = true
      @button.set_sensitive(false)
      @spinner.show
      @spinner.start

      Thread.new do
        begin
          yield
        ensure
          GLib::Idle.add do
            @spinner.stop
            @spinner.hide
            @button.set_sensitive(true)
            @loading = false
            false
          end
        end
      end
    end
  end
end
