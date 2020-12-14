module MittensUi
  module Widgets
    class Button
      def initialize(layout, options, &block)
        button_title  = options[:title] || "Button"

        margin_top    = options[:top].nil?    ? nil : options[:top]
        margin_bottom = options[:bottom].nil? ? nil : options[:bottom]
        margin_right  = options[:right].nil?  ? nil : options[:right]
        margin_left   = options[:left].nil?   ? nil : options[:left]

        @button = Gtk::Button.new(label: button_title)
 
        @button.set_margin_top(margin_top)        unless margin_top.nil?
        @button.set_margin_left(margin_left)      unless margin_left.nil?
        @button.set_margin_right(margin_right)    unless margin_right.nil?
        @button.set_margin_bottom(margin_bottom)  unless margin_bottom.nil?

        if layout
          layout.pack_start(@button)
        end
            
        @button.signal_connect "clicked" do |button_widget|
          block.call(button_widget)
        end
      end
      
      def remove
        return if @button.nil?
        @button.destroy
      end
    end
  end
end
