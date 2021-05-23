module MittensUi
  module Helpers
    def set_margin_from_opts_for(widget, options={})
      margin_top    = options[:top].nil?    ? nil : options[:top]
      margin_bottom = options[:bottom].nil? ? nil : options[:bottom]
      margin_right  = options[:right].nil?  ? nil : options[:right]
      margin_left   = options[:left].nil?   ? nil : options[:left]

      unless margin_top.nil?
        widget.set_margin_top(margin_top)
      end

      unless margin_bottom.nil?
        widget.set_margin_bottom(margin_bottom)
      end

      unless margin_left.nil?
        widget.set_margin_left(margin_left)
      end

      unless margin_right.nil?
        widget.set_margin_right(margin_right)
      end
    end
  end
end

