require_relative "./core"

module MittensUi
  class TableView < Core

    def initialize(options={})
      headers = options[:headers] || []
      data    = options[:data]    || []

      unless is_data_valid?(headers, data)
        exit 1
      end

      init_column_headers(headers)
      
      init_list_store
 
      @scrolled_window = Gtk::ScrolledWindow.new
      calc_min_height = (data.size ** 2 ) * 10
      @scrolled_window.min_content_height = calc_min_height

      @tree_view = Gtk::TreeView.new(@list_store)
      @tree_view.selection.set_mode(:single)

      @columns.each { |col| @tree_view.append_column(col) }
      
      init_sortable_columns
      
      init_data_rows(data) # Populate the @list_store
      
      @scrolled_window.add(@tree_view)

      super(@tree_view, options)
    end
    
    def add(data, direction=:append)
      return if data.size.zero?
      
      case direction
      when :append
        iter = @list_store.append
      when :prepend
        iter = @list_store.prepend
      else
        iter = @list_store.append
      end
        
      data.each_with_index do |item, idx|
        iter[idx] = item
      end
    end
    
    def clear
      @list_store.clear
    end

    def render
      $vertical_box.pack_start(@scrolled_window)
      return self
    end

    def row_count
      count = 0
      @list_store.each { |item| count += 1 }

      return count
    end

    def remove_selected
      iter = @tree_view.selection.selected

      values = []

      if iter.nil?
        return values
      end
      
      @list_store.n_columns.times do |x| 
        values << @list_store.get_value(iter, x)
      end
      
      @list_store.remove(iter)
      
      return values
    end
    
    def row_clicked
      @tree_view.signal_connect("row-activated") do |tv, path, column|
        row = tv.selection.selected

        values = []

        @list_store.n_columns.times { |x| values << row.get_value(x) if row }
        
        yield(values)
      end
    end

    def update(fresh_data=[])
      self.clear
      init_data_rows(fresh_data)
      @tree_view.set_model(@list_store)
    end

    private

    def is_data_valid?(headers, data)
      column_size = headers.size

      data_is_array    = data.class == Array
      headers_is_array = headers.class == Array

      valid = true

      unless data_is_array
        puts "=====[MittensUi: Critical Error]====="
        puts "Incoming data must be an Array of Arrays: data = [ [el..], [el...] ]"
        valid = false
        return valid
      end

      unless headers_is_array
        puts "=====[MittensUi: Critical Error]====="
        puts "Incoming data must be an Array of Arrays: data = [ [el..], [el...] ]"
        valid = false
        return valid
      end

      data.each_with_index do |row, idx|
        # Row data must be an Array.
        # The size of the Row Array must match the size of the Header columns.
        valid = (row.class == Array && column_size == row.size) ? true : false

        unless valid
          puts 
          puts "=====[MittensUi: Critical Error]====="
          puts "The length of your data(Row) must match the length of the headers."
          puts "Failed at Row:  #{idx}"
          puts "Row Length:     #{row.size} elements"
          puts "Header Length   #{column_size} elements"
          puts
          return valid
        end
      end
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
      types = []
      @columns.size.times { types << String }
      @list_store = Gtk::ListStore.new(*types)
    end
    
    def init_data_rows(data)
      data.each_with_index do |items_arr|
        iter = @list_store.append
        items_arr.each_with_index do |item, idx|
          iter[idx] = item
         end
      end
    end
    
    def init_column_headers(headers_list)
      renderer = Gtk::CellRendererText.new
      
      @columns = []
      
      headers_list.each_with_index do |h, i|
        next unless h.class == String
        @columns << Gtk::TreeViewColumn.new(h, renderer, text: i)
      end
    end
    
  end
end
