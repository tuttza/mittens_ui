require "mittens_ui/version"

require "mittens_ui/layouts/grid"
require "mittens_ui/layouts/box"

require "mittens_ui/widgets/alert"
require "mittens_ui/widgets/label"
require "mittens_ui/widgets/button"
require "mittens_ui/widgets/textbox"
require "mittens_ui/widgets/listbox"

require "gtk3"

module MittensUi
  class Error < StandardError; end

  def self.ListBox(layout, options = {})
    list_box = MittensUi::Widgets::ListBox.new(layout, options)
    Application.set_visible_elements(list_box)
    return list_box
  end

  def self.Alert(window, message, options = {})
    alert = MittensUi::Widgets::Alert.new(window, message, options)
    Application.set_visible_elements(alert)
    return alert
  end

  def self.Label(text, layout, options = {})
    label = MittensUi::Widgets::Label.new(text, layout, options)
    Application.set_visible_elements(label)
    return label
  end

  def self.Textbox(layout, options = {})
    textbox = MittensUi::Widgets::Textbox.new(layout, options)
    Application.set_visible_elements(textbox)
    return textbox
  end

  def self.Button(layout, options = {}, &block)
    raise Error.new("Button must be passed a block.") unless block_given?
    button = MittensUi::Widgets::Button.new(layout, options, &block)
    Application.set_visible_elements(button)
    return button
  end

  def self.HideVisible
    Application.visible_elements.each(&:remove)
    Application.reset_visible_elements
  end

  class Application
    class << self
      def Window(options = {}, &block)  
        @@visible_elements = []
        init_gtk_application(options, block)
      end

      def set_visible_elements(element)
        @@visible_elements << element
      end

      def visible_elements
        @@visible_elements
      end

      def reset_visible_elements
        @@visible_elements = []
      end
  
      private 

      def set_process_name(name)
        # Doesn't work in MacOS Activity Monitor or Windows Task Manager. It shows up as "Ruby".
        Process.setproctitle(name)
        $PROGRAM_NAME = name
      end

      def init_gtk_application(options, block)
        app_name    = options[:name].nil?       ? "mittens_ui_app" : options[:name]
        height      = options[:height].nil?     ? 600 : options[:height]
        width       = options[:width].nil?      ? 400 : options[:width]
        title       = options[:title].nil?      ? "Mittens App" : options[:title]
        can_resize  = options[:can_resize].nil? ? true : options[:can_resize]

        set_process_name(app_name)

        gtk_app_name = "org.gtk.mittens_ui.#{app_name}"

        app = Gtk::Application.new(gtk_app_name, :flags_none)

        app.signal_connect("activate") do |application|
          app_window = Gtk::ApplicationWindow.new(application)
          scrolled_window = Gtk::ScrolledWindow.new
          vertical_box = Gtk::Box.new(:vertical, 10)
          scrolled_window.add(vertical_box)
          app_window.add(scrolled_window)
          block.call(app_window, vertical_box)
          app_window.set_size_request(width, height)
          app_window.set_title(title)
          app_window.set_resizable(can_resize)
          app_window.show_all
        end

        app.run
      end
    end
  end

  class Job
    attr_reader :name, :status

    def initialize(name)
      @name = name
      @status = nil
    end

    def run(&block)
      job_t = Thread.new { |_t| yield }
      set_status(job_t)
    end

    private 
    def set_status(thread)
      @status = thread.status
    end
  end
end
