require_relative "./core"

module MittensUi
  module Widgets
    class Slider < Core
      def initialize(options={})
        start_value = options[:start_value].nil?    ? 1.0  : options[:start_value]
        stop_value  = options[:stop_value].nil?     ? 10.0 : options[:stop_value]
        step_value  = options[:step_value].nil?     ? 1.0  : options[:step_value]
        init_value  = options[:initial_value].nil?  ? 1.0  : options[:initial_value]

        @scale = Gtk::Scale.new(:horizontal, start_value, stop_value, step_value)
        @scale.digits = 0
        @scale.draw_value = true
        @scale.value = init_value

        super(@scale)
      end

      def move
        @scale.signal_connect "value_changed" do |scale_widget|
          yield(scale_widget)
        end
      end
      alias :slide :move

      def render
        $vertical_box.pack_start(@scale)
        return self
      end
      
    end
  end
end