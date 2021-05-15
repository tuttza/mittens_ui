require_relative "./core"

module MittensUi
  module Widgets
    class TableView < Core
      def initialize(options={})
        headers = options[:headers] || []
        data    = options[:data]    || []
        
        init_headers(headers)
        
        init_model
   
        @tree_view = Gtk::TreeView.new(@model)

        @columns.each { |col| @tree_view.append_column(col) }
        
        @tree_view.selection.set_mode(:single)
        
        init_data(data)
        
        $vertical_box.pack_start(@tree_view)

        super(@tree_view)
      end
      
      private
     
      def init_model
        types = []
        @columns.size.times { types << String }
        @model = Gtk::ListStore.new(*types)
      end
      
      def init_data(data)
        data.each do |arr|
          arr.each do |a|
          iter = @model.append
            iter[0] = a
          end
        end
      end
      
      def init_headers(headers_list)
        renderer = Gtk::CellRendererText.new
        renderer.background = "grey"
        
        @columns = []
        
        headers_list.each_with_index do |h, i|
          next unless h.class == String
          i = i + 1
          set_bg = ( 2 % i == 0 ) ? 1 : 0
          @columns << Gtk::TreeViewColumn.new(h, renderer, text: i-1, background_set: set_bg)
        end
      end
      
    end
  end
end
