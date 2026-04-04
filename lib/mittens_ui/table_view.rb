# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A tabular data widget with sortable columns, row selection, and optional
  # inline cell editing. Wraps {https://docs.gtk.org/gtk4/class.ColumnView.html Gtk::ColumnView}
  # backed by a {https://docs.gtk.org/gtk4/class.StringList.html Gtk::StringList}
  # inside a {https://docs.gtk.org/gtk4/class.ScrolledWindow.html Gtk::ScrolledWindow}.
  #
  # @example Basic table
  #   table = MittensUi::TableView.new(
  #     headers: ["Name", "Email"],
  #     data: [["John", "john@example.com"]]
  #   )
  #
  # @example Table with all columns editable
  #   table = MittensUi::TableView.new(
  #     headers: ["Name", "Email"],
  #     data: [["John", "john@example.com"]],
  #     editable: true
  #   )
  #
  # @example Table with specific columns editable
  #   table = MittensUi::TableView.new(
  #     headers: ["Name", "Email", "Phone"],
  #     data: [["John", "john@example.com", "555-1234"]],
  #     editable_columns: [0, 2]
  #   )
  class TableView < Core

    # Creates a new TableView widget.
    #
    # @param options [Hash] configuration options
    # @option options [Array<String>] :headers ([]) column header labels
    # @option options [Array<Array<String>>] :data ([]) initial table data,
    #   each element is an array of strings representing a row
    # @option options [Boolean] :editable (false) when true, all cells are editable
    # @option options [Array<Integer>] :editable_columns ([]) list of column indices
    #   that should be editable
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      @headers          = options.fetch(:headers, [])
      @data             = options.fetch(:data, [])
      @editable         = options.fetch(:editable, false)
      @editable_columns = options.fetch(:editable_columns, [])
      @on_cell_edited   = nil
      @on_row_clicked   = nil

      raise ArgumentError, 'Invalid table data' unless data_valid?(@headers, @data)

      init_store
      init_selection
      init_column_view
      init_columns
      init_data_rows(@data)

      @scrolled_window = Gtk::ScrolledWindow.new
      @scrolled_window.min_content_height = [@data.size * 30, 300].min
      @scrolled_window.set_child(@column_view)

      super(@scrolled_window, options)
    end

    # Adds a row to the table.
    #
    # @param data [Array<String>] the row data, one element per column
    # @param direction [Symbol] +:append+ (default) or +:prepend+
    # @return [void]
    # @example
    #   table.add(["Jane Doe", "jane@example.com"])
    #   table.add(["First", "first@example.com"], :prepend)
    def add(data, direction = :append)
      return if data.empty?

      encoded = encode_row(data)
      if direction == :prepend
        @store.splice(0, 0, [encoded])
      else
        @store.append(encoded)
      end
    end

    # Clears all rows from the table.
    #
    # @return [void]
    def clear
      @store.splice(0, @store.n_items, [])
    end

    # Returns the number of rows in the table.
    #
    # @return [Integer] the row count
    def row_count
      @store.n_items
    end

    # Returns the currently selected row as an array of strings.
    #
    # @return [Array<String>, nil] the selected row values or nil if nothing selected
    # @example
    #   table.selected_row  # => ["John", "john@example.com"]
    def selected_row
      pos = @selection.selected

      return nil if pos == Gtk::INVALID_LIST_POSITION

      decode_row(@store.get_string(pos))
    end

    # Removes the currently selected row and returns its values.
    #
    # @return [Array<String>] the removed row values, or empty array if nothing selected
    def remove_selected
      pos = @selection.selected

      return [] if pos == Gtk::INVALID_LIST_POSITION

      values = selected_row
      @store.remove(pos)
      values
    end

    # Connects a block to the row activation event.
    #
    # @yield [values] called when a row is activated
    # @yieldparam values [Array<String>] the values of the activated row
    # @return [void]
    # @example
    #   table.row_clicked { |row| puts row.inspect }
    def row_clicked(&block)
      @on_row_clicked = block
    end

    # Connects a block to the row activation event (double click/Enter)
    def row_double_clicked(&block)
      @on_row_double_clicked = block
    end

    # Returns true if a row is currently selected, false otherwise.
    #
    # @return [Boolean] true if a row is selected, false otherwise
    #
    # @example
    #   if table.row_selected?
    #     puts "A row is selected!"
    #   else
    #     puts "No row is selected."
    #   end
    def row_selected?
      @selection.selected != Gtk::INVALID_LIST_POSITION
    end

    # Connects a block to the cell edited event.
    #
    # @yield [row, col, new_value] called when a cell is edited
    # @yieldparam row [Integer] the row index
    # @yieldparam col [Integer] the column index
    # @yieldparam new_value [String] the new value
    # @return [void]
    # @example
    #   table.cell_edited { |row, col, value| puts "#{row},#{col} => #{value}" }
    def cell_edited(&block)
      @on_cell_edited = block
    end

    private

    # Encodes a row array as a pipe-delimited string for storage in StringList.
    #
    # @param row [Array<String>] the row data
    # @return [String] encoded row
    def encode_row(row)
      row.map { |v| v.to_s.gsub('|', '\\|') }.join('|')
    end

    # Decodes a pipe-delimited string back into a row array.
    #
    # @param str [String] the encoded row
    # @return [Array<String>] the decoded row
    def decode_row(str)
      str.split(/(?<!\\)\|/).map { |v| v.gsub('\\|', '|') }
    end

    # Initializes the Gtk::StringList backing store.
    # Each item encodes a full row as a pipe-delimited string.
    #
    # @return [void]
    def init_store
      @store = Gtk::StringList.new([])
    end

    # Initializes single selection model wrapping the store.
    #
    # @return [void]
    def init_selection
      @selection = Gtk::SingleSelection.new
      @selection.model = @store

      # Handle selection changes (single click)
      @selection.signal_connect('selection-changed') do
        pos = @selection.selected
        next if pos == Gtk::INVALID_LIST_POSITION

        decoded = decode_row(@store.get_string(pos))
        @on_row_clicked&.call(decoded)
      end
    end

    # Initializes the Gtk::ColumnView.
    #
    # @return [void]
    def init_column_view
      @column_view = Gtk::ColumnView.new(@selection)
      @column_view.reorderable = true

      # Handle row activation (double click/Enter)
      @column_view.signal_connect('activate') do |_, pos|
        next if pos == Gtk::INVALID_LIST_POSITION

        decoded = decode_row(@store.get_string(pos))
        @on_row_double_clicked&.call(decoded)
      end
    end

    # Initializes columns for each header.
    #
    # @return [void]
    def init_columns
      @headers.each_with_index do |header, col_idx|
        next unless header.is_a?(String)

        factory = Gtk::SignalListItemFactory.new

        factory.signal_connect('setup') do |_f, list_item|
          label = Gtk::Label.new('')
          label.xalign = 0
          list_item.child = label
        end

        factory.signal_connect('bind') do |_f, list_item|
          pos   = list_item.position
          row   = decode_row(@store.get_string(pos))
          value = row[col_idx] || ''
          list_item.child.label = value
        end

        column = Gtk::ColumnViewColumn.new(header, factory)
        column.resizable = true
        column.expand    = true
        @column_view.append_column(column)
      end
    end

    # Populates the store with initial data rows.
    #
    # @param data [Array<Array<String>>] the data rows
    # @return [void]
    def init_data_rows(data)
      data.each { |row| @store.append(encode_row(row)) }
    end

    # Returns true if the given column index should be editable.
    #
    # @param col_index [Integer] the column index
    # @return [Boolean]
    def column_editable?(col_index)
      return false # TODO: I need to figure how make editable cells in GTK4

      #@editable || @editable_columns.include?(col_index)
    end

    # Validates that headers and data are correctly structured.
    #
    # @param headers [Array<String>] column headers
    # @param data [Array<Array<String>>] table data
    # @return [Boolean]
    def data_valid?(headers, data)
      unless data.is_a?(Array) && headers.is_a?(Array)
        puts '=====[MittensUi: Critical Error]====='
        puts 'headers and data must both be Arrays'
        return false
      end

      data.each_with_index do |row, idx|
        unless row.is_a?(Array) && row.size == headers.size
          puts '=====[MittensUi: Critical Error]====='
          puts 'Row length must match header length.'
          puts "Failed at Row:  #{idx}"
          puts "Row Length:     #{row.size} elements"
          puts "Header Length:  #{headers.size} elements"
          return false
        end
      end
      true
    end
  end
end
