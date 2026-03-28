require_relative "./core"

module MittensUi
  class Listbox < Core
    attr_reader :items

    def initialize(options = {})
      @items = options[:items] || []
      @selected_value = nil
      list_store = Gtk::ListStore.new(String)
      @items.each do |i|
        iter = list_store.append
        iter[0] = i
      end
      renderer = Gtk::CellRendererText.new
      @gtk_combobox = Gtk::ComboBox.new(model: list_store)
      @gtk_combobox.pack_start(renderer, true)
      @gtk_combobox.set_attributes(renderer, "text" => 0)
      @gtk_combobox.set_cell_data_func(renderer) do |_layout, _cell_renderer, _model, iter|
        set_selected_value(iter[0])
      end
      @gtk_combobox.set_active(0)
      super(@gtk_combobox, options)
    end

    def selected_value
      @selected_value
    end

    def set_selected_value(value)
      @selected_value = value
    end
    alias :set_value :set_selected_value
  end
end