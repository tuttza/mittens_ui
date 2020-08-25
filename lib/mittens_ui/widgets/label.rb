module MittensUi
  module Widgets
    class Label
      class << self
        def init(text, options)
          layout = options[:layout]
          window = options[:window]

          label = Gtk::Label.new(text)
          
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