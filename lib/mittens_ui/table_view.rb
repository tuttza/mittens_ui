# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A simple, custom table widget built on Gtk::Grid.
  #
  # Features:
  # - Sorting with ▲ ▼ indicators
  # - Row selection (mouse + keyboard)
  # - Single & double click callbacks
  # - Pagination for large datasets (auto-enabled > 500 rows)
  # - Built-in pagination UI (Prev / Next buttons + page indicator)
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
  # @example Pagination (automatic)
  #   # Pagination UI appears automatically when data > 500 rows
  #
  class TableView < Core
    attr_reader :data, :headers, :selected_row_idx

    PAGE_THRESHOLD = 500
    PAGE_SIZE      = 100

    def initialize(headers = [], data = [], options = {})
      @headers = headers
      @data = data

      @row_widgets = []
      @header_labels = []
      @selected_row_idx = nil
      @sort_directions = {}
      @current_page = 0

      # ---------------------------
      # GTK Structure
      # ---------------------------

      @grid = Gtk::Grid.new
      @grid.set_column_spacing(0)
      @grid.set_row_spacing(0)

      @scroller = Gtk::ScrolledWindow.new
      @scroller.set_policy(:automatic, :automatic)
      @scroller.set_child(@grid)
      @scroller.set_vexpand(true)
      @scroller.set_min_content_height(300)
      @scroller.set_max_content_height(300)

      # Pagination UI
      @pagination_box = Gtk::Box.new(:horizontal, 10)
      @pagination_box.set_margin_top(10)
      @pagination_box.set_halign(:center)

      @prev_btn = Gtk::Button.new(label: '← Prev')
      @next_btn = Gtk::Button.new(label: 'Next →')
      @page_label = Gtk::Label.new('')

      @prev_btn.signal_connect('clicked') { prev_page }
      @next_btn.signal_connect('clicked') { next_page }

      @pagination_box.append(@prev_btn)
      @pagination_box.append(@page_label)
      @pagination_box.append(@next_btn)

      # Root container (important for Core)
      @container = Gtk::Box.new(:vertical, 0)
      @container.append(@scroller)
      @container.append(@pagination_box)

      super(@container, options)

      # Events
      @on_row_clicked = nil
      @on_row_double_clicked = nil
      @last_click_time = nil
      @last_clicked_row = nil

      setup_css
      setup_keyboard

      render_headers
      render_rows
      update_pagination_ui
    end

    # ---------------------------
    # Public API
    # ---------------------------

    def add(row, direction = :append)
      return if row.nil? || row.empty?

      direction == :prepend ? @data.unshift(row) : @data << row

      adjust_page_after_insert
      render_rows
      update_pagination_ui
    end

    def update_data(new_data)
      @data = new_data
      @current_page = 0
      render_rows
      update_pagination_ui
    end

    def row_selected?(idx = nil)
      return !@selected_row_idx.nil? if idx.nil?

      @selected_row_idx == idx
    end

    def selected_row
      return nil unless @selected_row_idx

      @data[@selected_row_idx]
    end

    def remove_selected
      return nil unless @selected_row_idx

      removed = @data.delete_at(@selected_row_idx)
      @selected_row_idx = nil
      render_rows
      update_pagination_ui
      removed
    end

    def row_clicked(&block)
      @on_row_clicked = block
    end

    def row_double_clicked(&block)
      @on_row_double_clicked = block
    end

    # ---------------------------
    # Pagination
    # ---------------------------

    def paginated_data
      return @data if @data.size <= PAGE_THRESHOLD

      start = @current_page * PAGE_SIZE
      @data.slice(start, PAGE_SIZE) || []
    end

    def next_page
      return if @data.size <= PAGE_THRESHOLD

      max_page = (@data.size / PAGE_SIZE.to_f).ceil - 1
      @current_page = [@current_page + 1, max_page].min
      render_rows
      update_pagination_ui
    end

    def prev_page
      return if @data.size <= PAGE_THRESHOLD

      @current_page = [@current_page - 1, 0].max
      render_rows
      update_pagination_ui
    end

    def adjust_page_after_insert
      return if @data.size <= PAGE_THRESHOLD

      @current_page = (@data.size / PAGE_SIZE.to_f).floor
    end

    def update_pagination_ui
      if @data.size <= PAGE_THRESHOLD
        @pagination_box.hide
        return
      end

      total_pages = (@data.size / PAGE_SIZE.to_f).ceil
      @page_label.set_label("#{@current_page + 1} / #{total_pages}")

      @prev_btn.set_sensitive(@current_page > 0)
      @next_btn.set_sensitive(@current_page < total_pages - 1)

      @pagination_box.show
    end

    # ---------------------------
    # Rendering
    # ---------------------------

    private

    def setup_css
      css = Gtk::CssProvider.new
      css.load(data: <<~CSS)
        box.table-cell {
          padding: 6px 10px;
          border-bottom: 1px solid #ddd;
          background-color: #ffffff;
        }

        box.header-cell {
          font-weight: bold;
          padding: 8px 10px;
          border-bottom: 2px solid #ccc;
          background-color: #f5f5f5;
        }

        box.row-even {
          background-color: #ffffff;
        }

        box.row-odd {
          background-color: #f7f7f7;
        }

        box.table-cell:hover {
          background-color: #e6f2ff;
        }

        box.row-selected {
          background-color: #cce0ff;
          color: #000000;
        }
      CSS

      Gtk::StyleContext.add_provider_for_display(
        Gdk::Display.default,
        css,
        Gtk::StyleProvider::PRIORITY_APPLICATION
      )
    end

    def render_headers
      @headers.each_with_index do |header, col_idx|
        label = Gtk::Label.new(header.to_s)
        label.set_xalign(0.0)
        label.set_hexpand(true)

        @header_labels[col_idx] = label

        box = Gtk::Box.new(:horizontal, 0)
        box.append(label)
        box.style_context.add_class('header-cell')

        gesture = Gtk::GestureClick.new
        gesture.signal_connect('pressed') { sort_column(col_idx) }
        box.add_controller(gesture)

        @grid.attach(box, col_idx, 0, 1, 1)
      end
    end

    def render_rows
      @row_widgets.each { |row| row.each { |w| @grid.remove(w) } }
      @row_widgets.clear

      rows = paginated_data

      rows.each_with_index do |row, visible_idx|
        actual_idx = visible_idx + (@current_page * PAGE_SIZE)
        base_class = visible_idx.even? ? 'row-even' : 'row-odd'
        widget_row = []

        row.each_with_index do |cell, col_idx|
          label = Gtk::Label.new(cell.to_s)
          label.set_xalign(0.0)
          label.set_hexpand(true)

          box = Gtk::Box.new(:horizontal, 0)
          box.append(label)

          box.style_context.add_class('table-cell')
          box.style_context.add_class(base_class)
          box.style_context.add_class('row-selected') if row_selected?(actual_idx)

          attach_click_handlers(box, actual_idx)

          @grid.attach(box, col_idx, visible_idx + 1, 1, 1)
          widget_row << box
        end

        @row_widgets << widget_row
      end

      @grid.show
      @row_widgets.flatten.each(&:show)
    end

    def attach_click_handlers(widget, row_idx)
      gesture = Gtk::GestureClick.new
      gesture.set_button(0)

      gesture.signal_connect('pressed') do |_g, _n, _x, _y|
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        if @last_click_time &&
           @last_clicked_row == row_idx &&
           (now - @last_click_time) < 0.3

          @on_row_double_clicked&.call(@data[row_idx])
        else
          GLib::Timeout.add(200) do
            @last_clicked_row == row_idx ? @on_row_clicked&.call(@data[row_idx]) : false
          end
        end

        @last_click_time = now
        @last_clicked_row = row_idx
        @selected_row_idx = row_idx

        render_rows
      end

      widget.add_controller(gesture)
    end

    def sort_column(col_idx)
      dir = @sort_directions[col_idx] ? :desc : :asc
      @sort_directions[col_idx] = !@sort_directions[col_idx]

      @header_labels.each_with_index do |lbl, i|
        lbl.set_label(@headers[i])
      end

      arrow = dir == :asc ? ' ▲' : ' ▼'
      @header_labels[col_idx].set_label(@headers[col_idx] + arrow)

      @data.sort_by! { |row| row[col_idx].to_s }
      @data.reverse! if dir == :desc

      render_rows
      update_pagination_ui
    end

    def setup_keyboard
      controller = Gtk::EventControllerKey.new

      controller.signal_connect('key-pressed') do |_ctrl, key, _, _|
        case key
        when Gdk::Keyval::KEY_Up
          move_selection(-1)
        when Gdk::Keyval::KEY_Down
          move_selection(1)
        when Gdk::Keyval::KEY_Return
          @on_row_double_clicked&.call(selected_row)
        end
      end

      @scroller.add_controller(controller)
    end

    def move_selection(delta)
      return if @data.empty?

      @selected_row_idx ||= 0
      @selected_row_idx = [[@selected_row_idx + delta, 0].max, @data.size - 1].min

      render_rows
    end
  end
end
