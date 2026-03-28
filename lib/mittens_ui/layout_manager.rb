module MittensUi
  class LayoutManager
    UNITS = { full: 12, half: 6, third: 4, quarter: 3 }

    def initialize(container)
      @container = container
      @grid = Gtk::Grid.new
      @grid.column_homogeneous = true
      @grid.row_spacing = 5
      @grid.column_spacing = 5
      @container.pack_start(@grid, expand: true, fill: true, padding: 0)
      @current_row = 0
      @current_col = 0
    end

    def add(gtk_widget, width:)
      units = UNITS.fetch(width, 12)

      # if it won't fit on current row, wrap
      if @current_col + units > 12
        @current_row += 1
        @current_col = 0
      end

      @grid.attach(gtk_widget, @current_col, @current_row, units, 1)
      @current_col += units

      # if we've filled the row, move to next
      if @current_col >= 12
        @current_row += 1
        @current_col = 0
      end
    end

    def remove(gtk_widget)
      @grid.remove(gtk_widget)
    end

    def includes?(gtk_widget)
      @grid.children.include?(gtk_widget)
    end

    def reorder(gtk_widget, position)
      # Gtk::Grid doesn't support reordering directly, so remove and re-attach at row 0
      @grid.remove(gtk_widget)
      @grid.attach(gtk_widget, 0, position, 12, 1)
      # shift everything else down
    end

    def add_at_top(gtk_widget)
      return if @grid.children.include?(gtk_widget)
      
      # shift all existing rows down by 1
      @grid.children.each do |child|
        top = @grid.child_get_property(child, "top-attach")
        @grid.child_set_property(child, "top-attach", top + 1)
      end

      @grid.attach(gtk_widget, 0, 0, 12, 1)
      @current_row += 1
    end

  end
end