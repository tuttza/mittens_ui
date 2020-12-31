module MittensUi
  module Widgets
    class Switch
      def initialize(options = {})
        @switch = Gtk::Switch.new
        @switch.set_active(false)

        margin_top    = options[:top].nil?     ? nil : options[:top]
        margin_bottom = options[:bottom].nil?  ? nil : options[:bottom]
        margin_right  = options[:right].nil?   ? nil : options[:right]
        margin_left   = options[:left].nil?    ? nil : options[:left]

        unless margin_top.nil?
          @switch.set_margin_top(margin_top)
        end

        unless margin_bottom.nil?
          @switch.set_margin_bottom(margin_top)
        end

        unless margin_left.nil?
          @switch.set_margin_left(margin_left)
        end

        unless margin_right.nil?
          @switch.set_margin_right(margin_right)
        end

        # We need a Grid within our global $vertical_box layout
        # in order to make the Widget look good (meaning not overly streched).
        grid = Gtk::Grid.new
        grid.set_column_spacing(1)
        grid.set_row_spacing(1)
        grid.attach(@switch, 0, 0, 1, 1) 
        
        $vertical_box.pack_start(grid)
      end

      def activate
        @switch.signal_connect('notify::active') do |switch_widget|
          switch_widget.active? ? switch_widget.set_active(true) : switch_widget.set_active(false)
          yield
        end
      end
      alias :on :activate

      def status
        @switch.active? ? 'on' : 'off'
      end

      def remove
        return if @switch.nil?
        @switch.destroy
      end
    end
  end
end