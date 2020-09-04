module MittensUi
  module Layouts
    class Box      
      def initialize(window, options={}, &block)
        box_spacing = options[:spacing].nil? ? 6 : options[:spacing]
        @box = Gtk::Box.new(:vertical, box_spacing)
        yield(self)
        window.add(@box)
      end

      def attach(widget, options)
        expand  = options[:expand].nil?   ? true : options[:expand]
        fill    = options[:fill].nil?     ? true : options[:fill]
        padding = options[:padding].nil?  ? 0    : options[:padding]

        filterd_options = {
          expaned: expand,
          fill: fill,
          padding: padding
        }.freeze

        case options.dig(:position)
        when :start
          @box.pack_start(widget, filterd_options)
        when :end
          @box.pack_end(widget, filterd_options)
        when nil
          @box.pack_start(widget, filterd_options)
        end
      end

      def remove
        return if @box.nil?
        @box.destroy
      end
    end
  end
end
