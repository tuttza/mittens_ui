module MittensUi
  module Widgets
    class Label
      def initialize(text, options)
        layout = options[:layout]
        window = options[:window]

        margin_top    = layout[:top].nil?       ? nil : layout[:top]
        margin_bottom = layout[:bottom].nil?    ? nil : layout[:bottom]
        margin_right  = layout[:right].nil?     ? nil : layout[:right]
        margin_left   = layout[:left].nil?      ? nil : layout[:left]

        @label = Gtk::Label.new(text)

        unless margin_top.nil?
          @label.set_margin_top(margin_top)
        end

        unless margin_bottom.nil?
          @label.set_margin_bottom(margin_top)
        end

        unless margin_left.nil?
          @label.set_margin_left(margin_left)
        end

        unless margin_right.nil?
          @label.set_margin_right(margin_right)
        end
        
        if layout[:grid]
          layout[:grid].attach(@label, layout)
        elsif layout[:box]
          layout[:box].attach(@label, layout)
        elsif window
          window.add_child(@label)
        end 
      end
      def remove
        return if @label.nil?
        @label.destroy
      end
    end
  end
end