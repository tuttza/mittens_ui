module MittensUi
  module Widgets
    class Button
      class << self
        def init(options, block = Proc.new)
          button_title  = options[:title] || "MittensUi Button"
          layout        = options[:layout]
          window        = options[:window]
      
          button = Gtk::Button.new(label: button_title)
         
          if layout[:grid]
            MittensUi::Layouts::Grid.attach(button, layout)
          elsif layout[:stack]
            MittensUi::Layouts::Stack.attach(button, layout)
          elsif layout[:box]
            MittensUi::Layouts::Box.attach(button, layout)
          elsif window
            window.add_child(button)
          end
             
          button.signal_connect "clicked" do |widget|
            block.call
          end
        end
      end
    end
  end
end