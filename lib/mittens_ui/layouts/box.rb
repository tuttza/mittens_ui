module MittensUi
  module Layouts
    class Box
      class << self
        def init(window, block = Proc.new)
          box = Gtk::Box.new(:vertical, 6)
          block.call(box)
          window.add(box)
        end

        def attach(widget, options)
          box_ref = options[:box]

          expand  = options.dig(:expand).nil?   ? true : options.dig(:expand)
          fill    = options.dig(:fill).nil?     ? true : options.dig(:fill)
          padding = options.dig(:padding).nil?  ? 0    : options.dig(:padding)

          filterd_options = {
            expaned: expand,
            fill: fill,
            padding: padding
          }.freeze

          case options.dig(:position)
          when :start
            box_ref.pack_start(widget, filterd_options)
          when :end
            box_ref.pack_end(widget, filterd_options)
          when nil
            box_ref.pack_start(widget, filterd_options)
          end
        end
      end
    end
  end
end