module MittensUi
  module Widgets
    class ListBox
      class << self
        def set_selected_value(value)
          @@selected_value = value
        end

        def get_selected_value
          @@selected_value
        end

        def init(options={})
          layout        = options[:layout]
          window        = options[:window]
          items         = options[:items]

          list_store = Gtk::ListStore.new(String)

          items.each do |i|
            iter = list_store.append
            iter[0] = i
          end

          renderer = Gtk::CellRendererText.new

          gtk_combobox = Gtk::ComboBox.new(model: list_store)
          gtk_combobox.pack_start(renderer, true)
          gtk_combobox.set_attributes(renderer, "text" => 0)
          gtk_combobox.set_cell_data_func(renderer) do |_layout, _cell_renderer, _model, iter|
            set_selected_value(iter[0])
          end

          if layout[:grid]
            MittensUi::Layouts::Grid.attach(gtk_combobox, layout)
          elsif layout[:stack]
            MittensUi::Layouts::Stack.attach(gtk_combobox, layout)
          elsif layout[:box]
            MittensUi::Layouts::Box.attach(gtk_combobox, layout)
          elsif window
            window.add_child(gtk_combobox)
          end

          return self
        end
      end
    end
  end
end

