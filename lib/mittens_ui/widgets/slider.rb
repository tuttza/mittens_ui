module MittensUi
  module Widgets
    class Slider
      def initialize(layout, options={}, &block)
        start_value = options[:start_value].nil?   ? 1.0  : options[:start_value]
        stop_value  = options[:stop_value].nil?    ? 10.0 : options[:stop_value]
        step_value  = options[:step_value].nil?    ? 1.0  : options[:step_value]

        @scale = Gtk::Scale.new(:horizontal, start_value, stop_value, step_value)
        @scale.digits = 0
        @scale.draw_value = true

        @scale.signal_connect "value_changed" do |scale_widget|
          block.call(scale_widget)
        end

        if layout
          layout.pack_start(@scale)
        end
      end

      def remove
        return if @scale.nil?
        @scale.destroy
      end
    end
  end
end