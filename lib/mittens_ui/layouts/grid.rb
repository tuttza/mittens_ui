module MittensUi
  module Layouts
    class Grid
      class << self
        def init(window, block = Proc.new)
          grid = Gtk::Grid.new
          block.call grid
          window.add_child(grid)
        end

        def attach(widget, options)
          grid          = options[:grid]
          grid_height   = options[:height]
          grid_width    = options[:width]
          grid_top      = options[:top]
          grid_left     = options[:left]

          if !grid.nil?
            grid.attach(widget, grid_left, grid_top, grid_width, grid_height)
          else
            raise "You much pass a MittensUI:Grid or pass the Main app Window via the options hash."
          end
        end

      end
    end
  end
end