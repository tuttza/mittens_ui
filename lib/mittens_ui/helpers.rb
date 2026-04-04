# frozen_string_literal: true

module MittensUi
  module Helpers
    def icon_map
      {
        add:    'list-add-symbolic',
        remove: 'list-remove-symbolic',
        add_green: 'add',
        remove_red: 'remove'
      }.freeze
    end

    def list_system_icons
      @theme = Gtk::IconTheme.default
      puts @theme.icons
    end

    def set_margin_from_opts_for(widget, options={})
      margin_top    = options[:top].nil?    ? nil : options[:top]
      margin_bottom = options[:bottom].nil? ? nil : options[:bottom]
      margin_right  = options[:right].nil?  ? nil : options[:right]
      margin_left   = options[:left].nil?   ? nil : options[:left]

      widget.set_margin_top(margin_top)       unless margin_top.nil?
      widget.set_margin_bottom(margin_bottom) unless margin_bottom.nil?
      widget.set_margin_start(margin_left)    unless margin_left.nil?
      widget.set_margin_end(margin_right)     unless margin_right.nil?
    end
  end
end
