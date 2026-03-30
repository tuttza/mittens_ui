require_relative "./core"

module MittensUi
  # A tabular data widget with sortable columns, row selection, and optional
  # inline cell editing. Wraps {https://docs.gtk.org/gtk3/class.TreeView.html Gtk::TreeView}
  # backed by a {https://docs.gtk.org/gtk3/class.ListStore.html Gtk::ListStore}
  # inside a {https://docs.gtk.org/gtk3/class.ScrolledWindow.html Gtk::ScrolledWindow}.
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
    #   that should be editable. Takes precedence over +:editable+ for fine-grained control.
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      headers          = options[:headers]          || []
      data             = options[:data]             || []
      @editable        = options[:editable]         || false
      @editable_columns = options[:editable_columns] || []

      raise ArgumentError, "Invalid table data" unless is_data_valid?(headers, data)

      init_column_headers(headers)
      init_list_store

      @scrolled_window = Gtk::ScrolledWindow.new
      @scrolled_window.min_content_height = [data.size * 30, 300].min

      @tree_view = Gtk::TreeView.new(@list_store)
      @tree_view.selection.set_mode(:single)
      @columns.each { |col| @tree_view.append_column(col) }

      init_sortable_columns
      init_data_rows(data)

      @scrolled_window.add(@tree_view)
      super(@scrolled_window, options)
    end

    # Adds a row to the table.
    #
    # @param data [Array<String>] the row data, one element per column
    # @param direction [Symbol] +:append+ (default) or +:prepend+
    # @return [void]
    # @example
    #   table.add(["Jane Doe", "jane@example.com"])
    #   table.add(["First Row", "first@example.com"], :prepend)
    def add(data, direction = :append)
      return if data.size.zero?
      iter = direction == :prepend ? @list_store.prepend : @list_store.append
      data.each_with_index { |item, idx| iter[idx] = item }
    end

    # Clears all rows from the table.
    #
    # @return [void]
    def clear
      @list_store.clear
    end

    # Returns the number of rows in the table.
    #
    # @return [Integer] the row count
    def row_count
      @list_store.iter_n_children(nil)
    end

    # Returns the currently selected row as an array of strings.
    #
    # @return [Array<String>, nil] the selected row values, or nil if nothing is selected
    # @example
    #   table.selected_row  # => ["John", "john@example.com"]
    def selected_row
      iter = @tree_view.selection.selected
      return nil unless iter
      @list_store.n_columns.times.map { |x| @list_store.get_value(iter, x) }
    end

    # Removes the currently selected row and returns its values.
    #
    # @return [Array<String>] the removed row values, or empty array if nothing selected
    def remove_selected
      iter = @tree_view.selection.selected
      return [] unless iter
      values = selected_row
      @list_store.remove(iter)
      values
    end

    # Connects a block to the row activation event (double-click or Enter key).
    #
    # @yield [values] called when a row is activated
    # @yieldparam values [Array<String>] the values of the activated row
    # @return [void]
    # @example
    #   table.row_clicked do |row|
    #     puts row.inspect
    #   end
    def row_clicked
      @tree_view.signal_connect("row-activated") do |tv, _path, _column|
        row    = tv.selection.selected
        values = @list_store.n_columns.times.map { |x| row.get_value(x) if row }.compact
        yield(values)
      end
    end

    # Connects a block to the cell edited event.
    # Called whenever the user finishes editing a cell inline.
    #
    # @yield [row, col, new_value] called when a cell is edited
    # @yieldparam row [Integer] the row index of the edited cell
    # @yieldparam col [Integer] the column index of the edited cell
    # @yieldparam new_value [String] the new value entered by the user
    # @return [void]
    # @example
    #   table.cell_edited do |row, col, value|
    #     puts "Row #{row}, Col #{col} changed to: #{value}"
    #   end
    def cell_edited(&block)
      @on_cell_edited = block
    end

    private

    # Returns true if the given column index should be editable.
    #
    # @param col_index [Integer] the column index
    # @return [Boolean]
    def column_editable?(col_index)
      @editable || @editable_columns.include?(col_index)
    end

    # @return [Boolean]
    def is_data_valid?(headers, data)
      unless data.is_a?(Array) && headers.is_a?(Array)
        puts "=====[MittensUi: Critical Error]====="
        puts "headers and data must both be Arrays"
        return false
      end
      data.each_with_index do |row, idx|
        unless row.is_a?(Array) && row.size == headers.size
          puts "=====[MittensUi: Critical Error]====="
          puts "The length of your data(Row) must match the length of the headers."
          puts "Failed at Row:  #{idx}"
          puts "Row Length:     #{row.size} elements"
          puts "Header Length:  #{headers.size} elements"
          return false
        end
      end
      true
    end

    # @return [void]
    def init_sortable_columns
      @columns.each_with_index do |col, idx|
        col.sort_indicator = true
        col.sort_column_id = idx
        col.signal_connect("clicked") do |w|
          w.sort_order = w.sort_order == :ascending ? :descending : :ascending
        end
      end
    end

    # @return [void]
    def init_list_store
      types = Array.new(@columns.size, String)
      @list_store = Gtk::ListStore.new(*types)
    end

    # @return [void]
    def init_data_rows(data)
      data.each do |items_arr|
        iter = @list_store.append
        items_arr.each_with_index { |item, idx| iter[idx] = item }
      end
    end

    # Initializes column headers, using an editable CellRendererText for
    # columns marked as editable, and a standard one for the rest.
    #
    # @param headers_list [Array<String>] the column header labels
    # @return [void]
    def init_column_headers(headers_list)
      @columns = headers_list.each_with_index.filter_map do |h, i|
        next unless h.is_a?(String)

        renderer = Gtk::CellRendererText.new

        if column_editable?(i)
          renderer.editable = true
          renderer.signal_connect("edited") do |_renderer, path, new_text|
            iter = @list_store.get_iter(path)
            if iter
              iter[i] = new_text
              row_index = path.to_s.to_i
              @on_cell_edited&.call(row_index, i, new_text)
            end
          end
        end

        Gtk::TreeViewColumn.new(h, renderer, text: i)
      end
    end
  end
end