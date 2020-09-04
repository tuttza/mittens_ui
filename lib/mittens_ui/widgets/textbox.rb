module MittensUi
  module Widgets
    class Textbox
      def initialize(options, block = Proc.new) 
        @textbox    = Gtk::Entry.new
        layout      = options[:layout]
        can_edit    = options[:can_edit].nil? ?  true : options[:can_edit]
        max_length  = options[:max_length].nil? ? 200 : options[:max_length]
        
        @textbox.set_editable(can_edit)
        @textbox.set_max_length(max_length)
        
        if layout[:grid]
          layout[:grid].attach(@textbox, layout)
        elsif layout[:box]
          layout[:box].attach(@textbox, layout)
        end

        return @textbox
      end

      def text
        @textbox.text
      end

      def remove
        return if @textbox.nil?
        @textbox.destroy
      end
    end
  end
end