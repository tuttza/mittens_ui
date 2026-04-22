# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A checkbox widget that can be toggled on and off.
  # Wraps {https://docs.gtk.org/gtk4/class.CheckButton.html Gtk::CheckButton}.
  #
  # @example Basic checkbox
  #   cb = MittensUi::Checkbox.new(label: "Enable notifications")
  #   cb.toggle { puts "toggled!" }
  #
  # @example With associated value
  #   cb = MittensUi::Checkbox.new(label: "Accept terms")
  #   cb.value = "accepted"
  #   cb.toggle { puts "value: #{cb.value}" }
  class Checkbox < Core
    attr_accessor :value

    # Creates a new Checkbox widget.
    #
    # @param options [Hash] configuration options
    # @option options [String] :label ("Checkbox") the checkbox label text
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      label    = options.fetch(:label, 'Checkbox')
      @value   = nil
      @checkbox = Gtk::CheckButton.new
      @checkbox.set_label(label.to_s)
      super(@checkbox, options)
    end

    # Connects a block to the toggle event.
    # Called whenever the checkbox is checked or unchecked.
    #
    # @yield called when the checkbox state changes
    # @return [void]
    def toggle
      @checkbox.signal_connect('toggled') do
        yield
      end
    end

    # Returns whether the checkbox is currently checked.
    #
    # @return [Boolean]
    def checked?
      @checkbox.active?
    end
  end
end
