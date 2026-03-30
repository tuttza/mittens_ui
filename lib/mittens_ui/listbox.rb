require_relative "./core"

module MittensUi
  # A dropdown list widget with optional search/filter functionality.
  # In standard mode wraps {https://docs.gtk.org/gtk3/class.ComboBox.html Gtk::ComboBox}.
  # In searchable mode, a {https://docs.gtk.org/gtk3/class.SearchEntry.html Gtk::SearchEntry}
  # is displayed above the dropdown and filters the list as the user types.
  #
  # @example Basic listbox
  #   lb = MittensUi::Listbox.new(items: ["Ruby", "Python", "Elixir"])
  #   puts lb.selected_value
  #
  # @example Searchable listbox
  #   lb = MittensUi::Listbox.new(items: ["Ruby", "Python", "Elixir"], searchable: true)
  #   puts lb.selected_value
  class Listbox < Core

    # The original unfiltered list of items.
    # @return [Array<String>]
    attr_reader :items

    # Creates a new Listbox widget.
    #
    # @param options [Hash] configuration options
    # @option options [Array<String>] :items ([]) the list of items to display
    # @option options [Boolean] :searchable (false) when true, a search entry
    #   is shown above the dropdown that filters items as the user types
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      @items          = options[:items]      || []
      @searchable     = options[:searchable] || false
      @search_placeholder_text = options[:search_placeholder_text] || "Search..."
      @selected_value = nil
      @search_term    = ""

      init_list_store
      init_filter
      init_combobox

      if @searchable
        init_search_entry
        @gtk_widget = build_container
      else
        @gtk_widget = @gtk_combobox
      end

      super(@gtk_widget, options)
    end

    # Returns the currently selected value.
    #
    # @return [String, nil] the selected item or nil if nothing is selected
    # @example
    #   lb.selected_value  # => "Ruby"
    def selected_value
      @selected_value
    end

    # Sets the selected value manually.
    #
    # @param value [String] the value to select
    # @return [String] the value that was set
    def set_selected_value(value)
      @selected_value = value
    end
    alias :set_value :set_selected_value

    # Resets the search filter and restores the full item list.
    # Only has effect when +:searchable+ is true.
    #
    # @return [void]
    def clear_search
      return unless @searchable
      @search_entry.text = ""
      @search_term = ""
      @filter.refilter
    end

    # Replaces the current items with a new list and resets the selection.
    #
    # @param new_items [Array<String>] the new list of items
    # @return [void]
    # @example
    #   lb.update_items(["Go", "Rust", "Zig"])
    def update_items(new_items)
      @items = new_items
      @list_store.clear
      @items.each do |i|
        iter = @list_store.append
        iter[0] = i
      end
      @selected_value = nil
      @gtk_combobox.set_active(0)
    end

    private

    # Initializes the backing Gtk::ListStore with the items list.
    # @return [void]
    def init_list_store
      @list_store = Gtk::ListStore.new(String)
      @items.each do |i|
        iter = @list_store.append
        iter[0] = i
      end
    end

    # Wraps the list store in a Gtk::TreeModelFilter for search filtering.
    # @return [void]
    def init_filter
      @filter = Gtk::TreeModelFilter.new(@list_store)
      @filter.set_visible_func do |_model, iter|
        @search_term.empty? || iter[0].downcase.include?(@search_term.downcase)
      end
    end

    # Initializes the Gtk::ComboBox using the filtered model.
    # @return [void]
    def init_combobox
      renderer = Gtk::CellRendererText.new
      @gtk_combobox = Gtk::ComboBox.new(model: @filter)
      @gtk_combobox.pack_start(renderer, true)
      @gtk_combobox.set_attributes(renderer, "text" => 0)
      @gtk_combobox.set_cell_data_func(renderer) do |_layout, _cell_renderer, _model, iter|
        set_selected_value(iter[0])
      end
      @gtk_combobox.set_active(0)
    end

    # Initializes the Gtk::SearchEntry and wires up the filter callback.
    # @return [void]
    def init_search_entry
      @search_entry = Gtk::SearchEntry.new
      @search_entry.placeholder_text = @search_placeholder_text
      @search_entry.signal_connect("search-changed") do |entry|
        @search_term = entry.text
        @filter.refilter
        @gtk_combobox.set_active(0)
      end
    end

    # Builds a vertical container with the search entry above the combobox.
    # @return [Gtk::Box] the container widget
    def build_container
      container = Gtk::Box.new(:vertical, 4)
      container.pack_start(@search_entry, expand: false, fill: true, padding: 0)
      container.pack_start(@gtk_combobox, expand: false, fill: true, padding: 0)
      container
    end
  end
end
