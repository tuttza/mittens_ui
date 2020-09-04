module MittensUi
  module Widgets
    class Button
      def initialize(options, &block)
        button_title  = options[:title] || "Button"
        layout        = options[:layout]
        window        = options[:window]
    
        margin_top    = layout[:top].nil?    ? nil : layout[:top]
        margin_bottom = layout[:bottom].nil? ? nil : layout[:bottom]
        margin_right  = layout[:right].nil?  ? nil : layout[:right]
        margin_left   = layout[:left].nil?   ? nil : layout[:left]

        @button = Gtk::Button.new(label: button_title)

        unless margin_top.nil?
          @button.set_margin_top(margin_top)
        end

        unless margin_left.nil?
          @button.set_margin_left(margin_left)
        end

        unless margin_right.nil?
          @button.set_margin_right(margin_right)
        end

        unless margin_bottom.nil?
          @button.set_margin_bottom(margin_bottom)
        end
        
        if layout[:grid]
          layout[:grid].attach(@button, layout)
        elsif layout[:box]
          layout[:box].attach(@button, layout)
        elsif window
          window.add_child(@button)
        end
            
        @button.signal_connect "clicked" do |widget|
          block.call
        end
      end
      
      def remove
        return if @button.nil?
        @button.destroy
      end
    end
  end
end
