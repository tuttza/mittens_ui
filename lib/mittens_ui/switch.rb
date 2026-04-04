# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A toggle switch widget that represents an on/off state.
  # Wraps {https://docs.gtk.org/gtk4/class.Switch.html Gtk::Switch} inside a
  # {https://docs.gtk.org/gtk4/class.Grid.html Gtk::Grid} for layout consistency.
  #
  # The switch can be toggled by the user and monitored for state changes via
  # the {#activate} method. The current state can be queried with {#status}.
  #
  # @example Basic switch
  #   switch = MittensUi::Switch.new
  #   switch.activate { |s| puts "Switch toggled: #{s.status}" }
  #
  # @example Using the alias
  #   switch = MittensUi::Switch.new
  #   switch.on { |s| puts "Current state: #{s.status}" }
  #
  # @example Checking switch state
  #   switch = MittensUi::Switch.new
  #   puts switch.status  # => :off
  class Switch < Core

    # Creates a new Switch widget initialized to the off state.
    #
    # The switch is placed inside a grid container for consistent layout
    # with other MittensUi widgets.
    #
    # @param options [Hash] configuration options
    # @option options [Symbol] :width (:full) column width in the layout grid.
    #   Accepted values are +:full+, +:half+, +:third+, +:quarter+
    # @option options [Boolean] :defer_render (false) when true, skips auto-rendering
    #   into the layout. Use when passing to a container like {HBox}.
    # @return [Switch] a new Switch instance
    def initialize(options = {})
      @switch = Gtk::Switch.new
      @switch.active = false

      @grid = Gtk::Grid.new
      @grid.column_spacing = 1
      @grid.row_spacing = 1

      @grid.attach(@switch, 0, 0, 1, 1)

      super(@grid, options)
    end

    # Registers a callback to be invoked when the switch state changes.
    #
    # The block receives the Switch instance as an argument, allowing you to
    # access the current state via {#status}. The callback is triggered every
    # time the user toggles the switch.
    #
    # @yield [switch] passes the Switch instance to the block
    # @yieldparam switch [Switch] the Switch widget that was toggled
    # @return [void]
    #
    # @example Respond to toggle
    #   switch = MittensUi::Switch.new
    #   switch.activate do |s|
    #     puts "Switch is now #{s.status}"
    #   end
    #
    # @see #on
    def activate
      @switch.signal_connect('notify::active') do |switch_widget|
        yield(self)
      end
    end

    # Alias for {#activate}.
    #
    # Provides a more concise syntax for registering state change callbacks.
    #
    # @yield [switch] passes the Switch instance to the block
    # @yieldparam switch [Switch] the Switch widget that was toggled
    # @return [void]
    #
    # @example Using the alias
    #   switch = MittensUi::Switch.new
    #   switch.on { |s| puts s.status }
    #
    # @see #activate
    alias :on :activate

    # Returns the current state of the switch.
    #
    # @return [Symbol] +:on+ if the switch is active, +:off+ if inactive
    #
    # @example Check current state
    #   switch = MittensUi::Switch.new
    #   switch.status  # => :off
    #
    #   switch.on { |s| puts s.status }  # => :on (when toggled)
    def status
      @switch.active? ? :on : :off
    end
  end
end
