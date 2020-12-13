module MittensUi
  module Widgets
    class Label
      def initialize(text, layout, options)
        margin_top    = options[:top].nil?     ? nil : options[:top]
        margin_bottom = options[:bottom].nil?  ? nil : options[:bottom]
        margin_right  = options[:right].nil?   ? nil : options[:right]
        margin_left   = options[:left].nil?    ? nil : options[:left]

        @label = Gtk::Label.new(text)

        unless margin_top.nil?
          @label.set_margin_top(margin_top)
        end

        unless margin_bottom.nil?
          @label.set_margin_bottom(margin_top)
        end

        unless margin_left.nil?
          @label.set_margin_left(margin_left)
        end

        unless margin_right.nil?
          @label.set_margin_right(margin_right)
        end

        if layout
          layout.pack_start(@label)
        end
      end

      def remove
        return if @label.nil?
        @label.destroy
      end
    end
  end
end