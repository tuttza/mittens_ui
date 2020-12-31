require_relative "./core"

module MittensUi
  module Widgets
    class Image < Core
      attr_reader :path

      def initialize(path, options = {})
        @path = File.join(path.strip)

        tooltip_text = options[:tooltip_text].nil? ? "" : options[:tooltip_text]
        width        = options[:width].nil?        ? 80 : options[:width]
        height       = options[:height].nil?       ? 80 : options[:height]

        pixbuf = GdkPixbuf::Pixbuf.new(file: @path, width: width, height: height)
        
        @image = Gtk::Image.new(pixbuf: pixbuf)
        @image.tooltip_text = tooltip_text

        set_margin_from_opts_for(@image, options)

        @event_box = Gtk::EventBox.new.add_child(@image)

        $vertical_box.pack_start(@event_box)

        super(@image)
      end

      def click 
        @event_box.signal_connect("button_press_event") do
          yield
        end    
      end
    end
  end
end