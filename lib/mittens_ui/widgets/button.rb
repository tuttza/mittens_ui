module MittensUi
  module Widgets
    class Button
      class << self
        def init(options, block = Proc.new)
          button_title  = options[:title] || "MittensUi Button"
          layout        = options[:layout]
          window        = options[:window]
      
          margin_top = options.dig(:top).nil? ? nil : options.dig(:top)
          margin_bottom = options.dig(:bottom).nil? ? nil : options.dig(:bottom)

          button = Gtk::Button.new(label: button_title)

          unless margin_top.nil?
            button.set_margin_top(margin_top)
          end

          unless margin_bottom.nil?
            button.set_margin_bottom(margin_top)
          end
         
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