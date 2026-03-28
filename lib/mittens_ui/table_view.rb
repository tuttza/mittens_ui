require_relative "./core"

module MittensUi
  class TableView < Core
    def initialize(options = {})
      headers = options[:headers] || []
      data    = options[:data]    || []

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

    def add(data, direction = :append)
      return if data.size.zero?
      iter = direction == :prepend ? @list_store.prepend : @list_store.append
      data.each_with_index { |item, idx| iter[idx] = item }
    end

    def clear
      @list_store.clear
    end

    def row_count
      @list_store.iter_n_children(nil)
    end

    def selected_row
      iter = @tree_view.selection.selected
      return nil unless iter
      @list_store.n_columns.times.map { |x| @list_store.get_value(iter, x) }
    end

    def remove_selected
      iter = @tree_view.selection.selected
      return [] unless iter
      values = selected_row
      @list_store.remove(iter)
      values
    end

    def row_clicked
      @tree_view.signal_connect("row-activated") do |tv, _path, _column|
        row = tv.selection.selected
        values = @list_store.n_columns.times.map { |x| row.get_value(x) if row }.compact
        yield(values)
      end
    end

    private

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

      return true
    end

    def init_sortable_columns
      @columns.each_with_index do |col, idx|
        col.sort_indicator = true
        col.sort_column_id = idx
        col.signal_connect('clicked') do |w|
          w.sort_order = w.sort_order == :ascending ? :descending : :ascending
        end
      end
    end

    def init_list_store
      types = Array.new(@columns.size, String)
      @list_store = Gtk::ListStore.new(*types)
    end

    def init_data_rows(data)
      data.each do |items_arr|
        iter = @list_store.append
        items_arr.each_with_index { |item, idx| iter[idx] = item }
      end
    end

    def init_column_headers(headers_list)
      renderer = Gtk::CellRendererText.new
      @columns = headers_list.each_with_index.filter_map do |h, i|
        Gtk::TreeViewColumn.new(h, renderer, text: i) if h.is_a?(String)
      end
    end
  end
end