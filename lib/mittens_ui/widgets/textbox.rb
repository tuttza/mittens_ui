module MittensUi
  module Widgets
    class Textbox
      class << self
        def init(options, block = Proc.new)
          textbox = Gtk::Entry.new
          layout      = options[:layout]
          can_edit    = options[:can_edit].nil? ?  true : options[:can_edit]
          max_length  = options[:max_length].nil? ? 200 : options[:max_length]
          textbox.set_editable(can_edit)
          textbox.set_max_length(max_length)
          
          if layout[:grid]
            MittensUi::Layouts::Grid.attach(textbox, layout)
          elsif layout[:stack]
            MittensUi::Layouts::Stack.attach(textbox, layout)
          elsif layout[:box]
            MittensUi::Layouts::Box.attach(textbox, layout)
          end

          textbox
        end
      end
    end
  end
end