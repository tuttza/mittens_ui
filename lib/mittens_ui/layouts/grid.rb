module MittensUi
  module Layouts
    class Grid
      def initialize(window, &block)
        @grid = Gtk::Grid.new
        yield(self)
        window.add_child(@grid)
      end

      def attach(widget, options)
        grid_height   = options[:height]
        grid_width    = options[:width]
        grid_top      = options[:top]
        grid_left     = options[:left]

        # Place widget next to each other in the direction determined by the “orientation” property
        # defaults to :horizontal.
        if options.size >= 1
          @grid.add(widget)
        end

        unless options[:attach_to].nil?
          return
          @grid.attach_next_to()
        else
          @grid.attach(widget, grid_left, grid_top, grid_width, grid_height)
        end
      end
    end
  end
end
