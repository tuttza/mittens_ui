module MittensUi
  module Widgets
    class Textbox
      def initialize(layout, options) 
        @textbox    = Gtk::Entry.new
        can_edit    = options[:can_edit].nil? ?  true : options[:can_edit]
        max_length  = options[:max_length].nil? ? 200 : options[:max_length]
        
        @textbox.set_editable(can_edit) unless can_edit.nil?
        @textbox.set_max_length(max_length) unless max_length.nil?

        if layout
          layout.pack_start(@textbox)
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
