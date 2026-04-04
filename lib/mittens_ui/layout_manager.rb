# frozen_string_literal: true

module MittensUi
  # Manages the placement of widgets in the application window using a
  # 12-unit column grid system backed by {https://docs.gtk.org/gtk4/class.Grid.html Gtk::Grid}.
  #
  # Widgets are placed left to right, wrapping to the next row automatically
  # when the current row is full. The column width of each widget is specified
  # in units from 1 to 12, with convenience symbols +:full+, +:half+, +:third+,
  # and +:quarter+.
  #
  # @example Adding widgets with different widths
  #   layout.add(label_widget,   width: :full)    # spans all 12 units
  #   layout.add(textbox_widget, width: :half)    # spans 6 units
  #   layout.add(button_widget,  width: :quarter) # spans 3 units
  class LayoutManager

    # Maps width symbols to their 12-unit column equivalents.
    # @return [Hash{Symbol => Integer}]
    UNITS = { full: 12, half: 6, third: 4, quarter: 3 }.freeze

    # Creates a new LayoutManager and attaches the grid to the container.
    #
    # @param container [Gtk::Box] the vertical box to attach the grid to
    def initialize(container)
      @container = container
      @grid = Gtk::Grid.new
      @grid.column_homogeneous = true
      @grid.row_spacing = 5
      @grid.column_spacing = 5
      @container.append(@grid)
      @current_row = 0
      @current_col = 0
    end

    # Adds a GTK widget to the grid at the current position.
    # Wraps to the next row automatically if the widget won't fit.
    #
    # @param gtk_widget [Gtk::Widget] the widget to add
    # @param width [Symbol] the column width. Accepted values are
    #   +:full+ (12), +:half+ (6), +:third+ (4), +:quarter+ (3)
    # @return [void]
    # @example
    #   layout.add(label.core_widget, width: :full)
    #   layout.add(btn.core_widget,   width: :half)
    def add(gtk_widget, width:)
      units = UNITS.fetch(width, 12)

      if @current_col + units > 12
        @current_row += 1
        @current_col = 0
      end

      @grid.attach(gtk_widget, @current_col, @current_row, units, 1)
      @current_col += units

      if @current_col >= 12
        @current_row += 1
        @current_col = 0
      end
    end

    # Removes a widget from the grid.
    # Does nothing if the widget is not currently in the grid.
    #
    # @param gtk_widget [Gtk::Widget] the widget to remove
    # @return [void]
    def remove(gtk_widget)
      return unless includes?(gtk_widget)

      @grid.remove(gtk_widget)
    end

    # Returns whether a widget is currently in the grid.
    # Traverses the grid's child widget linked list.
    #
    # @param gtk_widget [Gtk::Widget] the widget to check for
    # @return [Boolean] true if the widget is in the grid, false otherwise
    def includes?(gtk_widget)
      child = @grid.first_child
      while child
        return true if child == gtk_widget

        child = child.next_sibling
      end
      false
    end

    # Moves a widget to a specific row position in the grid.
    # Removes the widget from its current position and reattaches it
    # at column 0 of the given row, spanning all 12 units.
    #
    # @param gtk_widget [Gtk::Widget] the widget to reorder
    # @param position [Integer] the row index to move the widget to
    # @return [void]
    def reorder(gtk_widget, position)
      @grid.remove(gtk_widget)
      @grid.attach(gtk_widget, 0, position, 12, 1)
    end

    # Adds a widget to the top of the grid at row 0, shifting all existing
    # widgets down by one row. Used by {MittensUi::Notify} to ensure
    # notification banners always appear at the top of the window.
    # Does nothing if the widget is already in the grid.
    #
    # @param gtk_widget [Gtk::Widget] the widget to add at the top
    # @return [void]
    def add_at_top(gtk_widget)
      return if includes?(gtk_widget)

      child = @grid.first_child
      while child
        layout_child = @grid.layout_manager.get_layout_child(child)
        layout_child.row = layout_child.row + 1
        child = child.next_sibling
      end

      @grid.attach(gtk_widget, 0, 0, 12, 1)
      @current_row += 1
    end
  end
end
