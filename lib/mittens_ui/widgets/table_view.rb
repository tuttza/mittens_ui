require_relative "./core"

module MittensUi
  module Widgets
    class TableView < Core
      def initialize(options={})
        headers = options[:headers] || []
        data    = options[:data]    || []

        init_column_headers(headers)
        
        init_list_store
   
        @tree_view = Gtk::TreeView.new(@list_store)
        @tree_view.selection.set_mode(:single)

        
        @columns.each { |col| @tree_view.append_column(col) }
        
        init_sortable_columns
        
        init_data_rows(data)
        
        $vertical_box.pack_start(@tree_view)

        super(@tree_view)
      end
      
      def add(data, direction=:append)
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
       
      def remove_selected
        iter = @tree_view.selection.selected
        iter ? @list_store.remove(iter) : nil
      end
      
      private
      
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
end
