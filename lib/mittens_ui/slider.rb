require_relative "./core"

module MittensUi
  class Slider < Core
    def initialize(options = {})
      start_value = options[:start_value]    || 1.0
      stop_value  = options[:stop_value]     || 10.0
      step_value  = options[:step_value]     || 1.0
      init_value  = options[:initial_value]  || 1.0
      @scale = Gtk::Scale.new(:horizontal, start_value, stop_value, step_value)
      @scale.digits = 0
      @scale.draw_value = true
      @scale.value = init_value
      super(@scale, options)
    end

    def move
      @scale.signal_connect("value_changed") do |scale_widget|
        yield(scale_widget)
      end
    end
    alias :slide :move
  end
end