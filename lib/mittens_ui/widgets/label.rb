module MittensUi
  module Widgets
    class Label
      class << self
        def init(text, options)
          layout = options[:layout]
          window = options[:window]

          margin_top = options.dig(:top).nil? ? nil : options.dig(:top)
          margin_bottom = options.dig(:bottom).nil? ? nil : options.dig(:bottom)
          
          label = Gtk::Label.new(text)

          unless margin_top.nil?
            label.set_margin_top(margin_top)
          end

          unless margin_bottom.nil?
            label.set_margin_bottom(margin_top)
          end
          
          if layout[:grid]
            MittensUi::Layouts::Grid.attach(label, layout)
          elsif layout[:stack]
            MittensUi::Layouts::Stack.attach(label, layout)
          elsif layout[:box]
            MittensUi::Layouts::Box.attach(label, layout)
          elsif window
            window.add_child(label)
          end
        end
      end
    end
  end
end