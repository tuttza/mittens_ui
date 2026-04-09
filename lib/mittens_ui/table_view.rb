# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A simple, but custom table widget built on {Gtk::Grid}.
  #
  # Provides:
  # - Column headers with sorting (▲ ▼ indicators)
  # - Row selection
  # - Single-click and double-click callbacks
  # - Dynamic row insertion
  # - Dark mode friendly styling
  #
  # @example Basic usage
  #   table = MittensUi::TableView.new(
  #     ['Name', 'Email'],
  #     [['John', 'john@example.com']]
  #   )
  #
  # @example Add row
  #   table.add(['Jane', 'jane@example.com'])
  #
  # @example Click handlers
  #   table.row_clicked { |row| puts row.inspect }
  #   table.row_double_clicked { |row| puts "Double: #{row.inspect}" }
  #
  class TableView < Core
    attr_reader :data, :headers, :selected_row_idx

    # @param headers [Array<String>] column headers
    # @param data [Array<Array<String>>] initial rows
    # @param options [Hash] Core layout options
    def initialize(headers = [], data = [], options = {})
      @headers = headers
      @data = data
      @row_widgets = []
      @header_labels = []
      @selected_row_idx = nil
      @sort_directions = {}

      @grid = Gtk::Grid.new
      @grid.set_column_spacing(0)
      @grid.set_row_spacing(0)

      @scroller = Gtk::ScrolledWindow.new
      @scroller.set_policy(:automatic, :automatic)
      @scroller.set_child(@grid)

      # Calculate height of table:
      row_height = 21
      header_height = 40
      max_height = 300
      desired_height = [(@data.size * row_height) + header_height, max_height].min

      # Set the scroller's min and max height
      @scroller.set_min_content_height(desired_height)
      @scroller.set_max_content_height(desired_height)

      super(@scroller, options)

      # Click handling
      @on_row_clicked = nil
      @on_row_double_clicked = nil
      @last_click_time = nil
      @last_clicked_row = nil

      setup_css
      render_headers
      render_rows
    end

    # ---------------------------
    # Public API
    # ---------------------------

    # Add a row to the table
    #
    # @param row [Array<String>] row data
    # @param direction [Symbol] :append or :prepend
    # @return [void]
    def add(row, direction = :append)
      return if row.nil? || row.empty?

      if direction == :prepend
        @data.unshift(row)
      else
        @data << row
      end

      render_rows
    end

    # Replace table data
    #
    # @param new_data [Array<Array<String>>]
    def update_data(new_data)
      @data = new_data
      render_rows
    end

    # Check if a row is selected
    #
    # @param idx [Integer, nil]
    # @return [Boolean]
    def row_selected?(idx = nil)
      return !@selected_row_idx.nil? if idx.nil?

      @selected_row_idx == idx
    end

    # Get selected row data
    #
    # @return [Array<String>, nil]
    def selected_row
      return nil unless @selected_row_idx

      @data[@selected_row_idx]
    end

    # Remove selected row
    #
    # @return [Array<String>, nil]
    def remove_selected
      return nil unless @selected_row_idx

      removed = @data.delete_at(@selected_row_idx)
      @selected_row_idx = nil
      render_rows
      removed
    end

    # Register single-click handler
    #
    # @yield [row] row data
    def row_clicked(&block)
      @on_row_clicked = block
    end

    # Register double-click handler
    #
    # @yield [row] row data
    def row_double_clicked(&block)
      @on_row_double_clicked = block
    end

    # ---------------------------
    # Rendering
    # ---------------------------

    private

    def setup_css
      css = Gtk::CssProvider.new
      css.load(data: <<~CSS)
        frame {
          border-radius: 0;
          box-shadow: none;
          border: none;
        }

        .table-cell {
          padding: 6px 10px;
          border-bottom: 1px solid @borders;
        }

        .header-cell {
          font-weight: bold;
          padding: 8px 10px;
          border-bottom: 2px solid @borders;
          background-color: @theme_base_color;
        }

        .row-even {
          background-color: shade(@theme_bg_color, 1.02);
        }

        .row-odd {
          background-color: shade(@theme_bg_color, 0.98);
        }

        .table-cell:hover {
          background-color: alpha(@theme_selected_bg_color, 0.25);
        }

        .row-selected {
          background-color: @theme_selected_bg_color;
          color: @theme_selected_fg_color;
        }
      CSS

      Gtk::StyleContext.add_provider_for_display(
        Gdk::Display.default,
        css,
        Gtk::StyleProvider::PRIORITY_USER
      )
    end

    def render_headers
      @headers.each_with_index do |header, col_idx|
        label = Gtk::Label.new(header.to_s)
        label.set_xalign(0.0)
        label.set_hexpand(true)

        @header_labels[col_idx] = label

        frame = Gtk::Frame.new
        frame.set_child(label)
        frame.set_hexpand(true)
        frame.style_context.add_class('header-cell')

        gesture = Gtk::GestureClick.new
        gesture.set_button(0)
        gesture.signal_connect('pressed') do |_g, _n, _x, _y|
          sort_column(col_idx)
        end
        frame.add_controller(gesture)

        @grid.attach(frame, col_idx, 0, 1, 1)
      end
    end

    def render_rows
      @row_widgets.each { |row| row.each { |w| @grid.remove(w) } }
      @row_widgets.clear

      @data.each_with_index do |row, row_idx|
        base_class = row_idx.even? ? 'row-even' : 'row-odd'
        widget_row = []

        row.each_with_index do |cell, col_idx|
          label = Gtk::Label.new(cell.to_s)
          label.set_xalign(0.0)
          label.set_hexpand(true)

          cell_box = Gtk::Box.new(:horizontal, 0)
          cell_box.set_hexpand(true)

          label = Gtk::Label.new(cell.to_s)
          label.set_xalign(0.0)
          label.set_hexpand(true)

          cell_box.append(label)

          cell_box.style_context.add_class('table-cell')
          cell_box.style_context.add_class(base_class)
          cell_box.style_context.add_class('row-selected') if row_selected?(row_idx)

          gesture = Gtk::GestureClick.new
          gesture.set_button(0)

          gesture.signal_connect('pressed') do |_g, _n, _x, _y|
            now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            if @last_click_time &&
               @last_clicked_row == row_idx &&
               (now - @last_click_time) < 0.3

              # DOUBLE CLICK
              @on_row_double_clicked&.call(@data[row_idx])
            else
              # SINGLE CLICK (delayed slightly to avoid conflict)
              GLib::Timeout.add(250) do
                @last_clicked_row == row_idx ? @on_row_clicked&.call(@data[row_idx]) : false
              end
            end

            @last_click_time = now
            @last_clicked_row = row_idx
            @selected_row_idx = row_idx

            render_rows
          end

          cell_box.add_controller(gesture)

          @grid.attach(cell_box, col_idx, row_idx + 1, 1, 1)
          widget_row << cell_box
        end

        @row_widgets << widget_row
      end

      @grid.show
      @row_widgets.flatten.each(&:show)
    end

    def sort_column(col_idx)
      dir = @sort_directions[col_idx] ? :desc : :asc
      @sort_directions[col_idx] = !@sort_directions[col_idx]

      @header_labels.each_with_index do |lbl, i|
        lbl&.set_label(@headers[i].to_s)
      end

      arrow = dir == :asc ? '  ▲' : '  ▼'
      @header_labels[col_idx].set_label(@headers[col_idx] + arrow)

      @data.sort_by! { |row| row[col_idx].to_s }
      @data.reverse! if dir == :desc

      render_rows
    end
  end
end
