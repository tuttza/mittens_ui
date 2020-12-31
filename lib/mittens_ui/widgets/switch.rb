require_relative "./core"

module MittensUi
  module Widgets
    class Switch < Core
      def initialize(options = {})
        @switch = Gtk::Switch.new
        @switch.set_active(false)

        set_margin_from_opts_for(@switch, options)

        # We need a Grid within our global $vertical_box layout
        # in order to make the Widget look good (meaning not overly streched).
        grid = Gtk::Grid.new
        grid.set_column_spacing(1)
        grid.set_row_spacing(1)
        grid.attach(@switch, 0, 0, 1, 1) 
        
        $vertical_box.pack_start(grid)

        super(@switch)
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
    end
  end
end