require_relative "./core"
module MittensUi
  class Image < Core
    attr_reader :path

    def initialize(path, options = {})
      @path        = path.strip
      tooltip_text = options[:tooltip_text] || ""
      width        = options[:width]        || 80
      height       = options[:height]       || 80

      if @path.include?(".gif")
        pixbuf = GdkPixbuf::PixbufAnimation.new(@path)
        @image = Gtk::Image.new(animation: pixbuf)
      else
        pixbuf = GdkPixbuf::Pixbuf.new(file: @path, width: width, height: height)
        @image = Gtk::Image.new(pixbuf: pixbuf)
      end

      @image.tooltip_text = tooltip_text
      @event_box = Gtk::EventBox.new.add_child(@image)
      super(@event_box, options)
    end

    def click
      @event_box.signal_connect("button_press_event") do
        yield
      end
    end
  end
end