# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A dropdown list widget with optional search/filter functionality.
  # Wraps {https://docs.gtk.org/gtk4/class.DropDown.html Gtk::DropDown}
  # backed by {https://docs.gtk.org/gtk4/class.StringList.html Gtk::StringList}.
  # In searchable mode, a search entry is displayed above the dropdown
  # and filters the list as the user types.
  #
  # @example Basic listbox
  #   lb = MittensUi::Listbox.new(items: ['Ruby', 'Python', 'Elixir'])
  #   puts lb.selected_value
  #
  # @example Searchable listbox
  #   lb = MittensUi::Listbox.new(items: ['Ruby', 'Python', 'Elixir'], searchable: true)
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
    # @option options [String] :search_placeholder_text ("Search...") placeholder
    #   text shown in the search entry
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      @items                   = options[:items]                    || []
      @searchable              = options[:searchable]               || false
      @search_placeholder_text = options[:search_placeholder_text] || 'Search...'
      @selected_value          = nil
      @search_term             = ''
      @filtered_items          = @items.dup

      init_store
      init_dropdown

      if @searchable
        init_search_entry
        @gtk_widget = build_container
      else
        @gtk_widget = @dropdown
      end

      super(@gtk_widget, options)
    end

    # Returns the currently selected value.
    #
    # @return [String, nil] the selected item or nil if nothing is selected
    # @example
    #   lb.selected_value  # => "Ruby"
    def selected_value
      pos = @dropdown.selected
      return nil if pos == Gtk::INVALID_LIST_POSITION

      @filtered_items[pos]
    end

    # Sets the selected value manually.
    #
    # @param value [String] the value to select
    # @return [String, nil] the value that was set, or nil if not found
    def set_selected_value(value)
      idx = @filtered_items.index(value)
      @dropdown.selected = idx if idx
      value
    end
    alias set_value set_selected_value

    # Resets the search filter and restores the full item list.
    # Only has effect when +:searchable+ is true.
    #
    # @return [void]
    def clear_search
      return unless @searchable

      @search_entry.text = ''
      @search_term = ''
      rebuild_store(@items)
    end

    # Replaces the current items with a new list and resets the selection.
    #
    # @param new_items [Array<String>] the new list of items
    # @return [void]
    # @example
    #   lb.update_items(['Go', 'Rust', 'Zig'])
    def update_items(new_items)
      @items = new_items
      rebuild_store(@items)
    end

    private

    # Initializes the Gtk::StringList backing store.
    #
    # @return [void]
    def init_store
      @store = Gtk::StringList.new(@items)
    end

    # Initializes the Gtk::DropDown with the string list model.
    #
    # @return [void]
    def init_dropdown
      # GTK4: Gtk::DropDown replaces Gtk::ComboBox
      @dropdown = Gtk::DropDown.new(@store, nil)
      @dropdown.selected = 0 unless @items.empty?
    end

    # Initializes the search entry and wires up the filter callback.
    #
    # @return [void]
    def init_search_entry
      @search_entry = Gtk::SearchEntry.new
      @search_entry.placeholder_text = @search_placeholder_text
      @search_entry.signal_connect('search-changed') do |entry|
        @search_term = entry.text
        filtered = @items.select { |i| i.downcase.include?(@search_term.downcase) }
        rebuild_store(filtered)
      end
    end

    # Rebuilds the StringList store with a new set of items.
    #
    # @param new_items [Array<String>] the items to display
    # @return [void]
    def rebuild_store(new_items)
      @filtered_items = new_items
      @store.splice(0, @store.n_items, new_items)
      @dropdown.selected = 0 unless new_items.empty?
    end

    # Builds a vertical container with the search entry above the dropdown.
    #
    # @return [Gtk::Box] the container widget
    def build_container
      container = Gtk::Box.new(:vertical, 4)
      container.append(@search_entry)
      container.append(@dropdown)
      container
    end
  end
end
