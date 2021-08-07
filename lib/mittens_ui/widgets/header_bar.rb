require_relative "./core"

module MittensUi
  module Widgets
    class HeaderBar < Core
      def initialize(widgets, options = {}, &block)
        title     = options[:title].nil? ? "" : options[:title]
        position  = options[:position].nil? ? :start : options[:position]

        box = Gtk::Box.new(:horizontal, 0)
        box.style_context.add_class("linked")

        @header = Gtk::HeaderBar.new
        @header.show_close_button = true
        @header.title = title
        @header.has_subtitle = false

        widgets.each do |w|
          w.remove
          case position
          when :start
            box.pack_start(w.core_widget)
          when :end
            box.pack_end(w.core_widget)
          else
            box.pack_start(w.core_widget)
          end  
        end

        if position == :start 
          @header.pack_start(box)
        end

        if position == :end
          @header.pack_end(box)
        end

        $app_window.titlebar = @header
        $vertical_box.pack_start(@header)

        yield(widgets)

        super(@header, options)
      end

    end
  end
end