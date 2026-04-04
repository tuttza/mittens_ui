# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A horizontal slider widget for selecting values from a range.
  #
  # The `Slider` class allows users to select a value within a specified range
  # by dragging a handle along a horizontal track. It emits a signal when the
  # value changes, enabling callbacks to be executed.
  #
  # @example Create a slider with custom range and initial value
  #   slider = MittensUi::Slider.new(
  #     start_value: 0,
  #     stop_value: 100,
  #     initial_value: 50
  #   )
  class Slider < Core
    # Initializes a new Slider widget.
    #
    # @param [Hash] options The options for configuring the slider.
    # @option options [Float] :start_value The minimum value of the slider (default: 1.0).
    # @option options [Float] :stop_value The maximum value of the slider (default: 10.0).
    # @option options [Float] :step_value The step increment for the slider (default: 1.0).
    # @option options [Float] :initial_value The initial value of the slider (default: 1.0).
    def initialize(options = {})
      start_value = options.fetch(:start_value, 1.0)
      stop_value  = options.fetch(:stop_value, 10.0)
      step_value  = options.fetch(:step_value, 1.0)
      init_value  = options.fetch(:initial_value, 1.0)

      adjustment = Gtk::Adjustment.new(
        init_value,
        start_value,
        stop_value,
        step_value,
        step_value,
        0
      )

      @scale = Gtk::Scale.new(:horizontal, adjustment)
      @scale.set_digits(0)
      @scale.set_draw_value(true)

      super(@scale, options)
    end

    # Registers a callback to be executed when the slider value changes.
    #
    # The block will be called with the new slider value as its argument.
    #
    # @yield [value] The block to execute when the slider value changes.
    # @yieldparam [Float] value The new value of the slider.
    # @return [void]
    #
    # @example Register a callback
    #   slider.move do |value|
    #     puts "Slider value changed to #{value}"
    #   end
    def move
      @scale.signal_connect('value_changed') do |scale_widget|
        yield(scale_widget.value)
      end
    end
    alias slide move
  end
end
