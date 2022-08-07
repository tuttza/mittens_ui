require_relative "./core"

module MittensUi
  class HeaderBar < Core
    def initialize(widgets, options = {})
      title     = options[:title].nil?    ? ""    : options[:title]
      position  = options[:position].nil? ? :left : options[:position]

      box = Gtk::Box.new(:horizontal, 0)
      box.style_context.add_class("linked")

      @header = Gtk::HeaderBar.new
      @header.show_close_button = true
      @header.title = title
      @header.has_subtitle = false

      unless widgets.nil? 
        widgets.each do |w|
          w.remove
          case position
          when :left
            box.pack_start(w.core_widget)
          when :right
            box.pack_end(w.core_widget)
          else
            box.pack_start(w.core_widget)
          end  
        end
      end

      if position == :left 
        @header.pack_start(box)
      end

      if position == :right
        @header.pack_end(box)
      end

      super(@header, options)
    end

    def render
      $app_window.titlebar = @header
      return self
    end

  end
end
