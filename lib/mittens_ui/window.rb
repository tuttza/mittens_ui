require_relative "./core"

module MittensUi
  class Window < Core
    attr_reader :widgets

    def initialize(options={})
      title    = options[:title].nil?  ? "Window" : options[:title]
      @widgets = options[:widgets].nil? ? {}     : options[:widgets]
      init_window
      @window.title = title
    end

    def render
      @window.show_all unless @window.active?
      return self
    end

    def close
      @window.close
    end

    private

    def init_window
      @window = Gtk::Window.new
      @window.transient_for = $app_window

      scrolled_window = Gtk::ScrolledWindow.new
      @vbox = Gtk::Box.new(:vertical, 10)
      scrolled_window.add(@vbox)
      @window.add(scrolled_window)

      @window.set_size_request(400, 300)

      interrupt_window_destroy

      add_widgets
    end

    def add_widgets
      @widgets.each do |widget|
        @vbox.pack_start(widget.core_widget)
      end
    end

    # This methhod is used to prevent the 'delete-event'
    # from actually destroying the Gtk window object 
    # from memory. This allows us to re-open the window after
    # it has been closed.
    def interrupt_window_destroy
      @window.signal_connect("delete-event") do 
        @window.hide
        true
      end
    end
  end
end
