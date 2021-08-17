require "mittens_ui/version"
require "mittens_ui/alert"
require "mittens_ui/label"
require "mittens_ui/button"
require "mittens_ui/textbox"
require "mittens_ui/listbox"
require "mittens_ui/slider"
require "mittens_ui/switch"
require "mittens_ui/image"
require "mittens_ui/checkbox"
require "mittens_ui/web_link"
require "mittens_ui/table_view"
require "mittens_ui/loader"
require "mittens_ui/header_bar"
require "mittens_ui/file_picker"
require "mittens_ui/file_menu"
require "mittens_ui/hbox"

require "gtk3"

module MittensUi
  class Error < StandardError; end
  
  def self.Shutdown(&block)
    $app_window.signal_connect("delete-event") do |_widget| 
      puts "delete-event detected..."
      yield
    end
  end

  class Application
    class << self
      def Window(options = {}, &block)
        init_gtk_application(options, &block)
      end

      private

      def set_process_name(name)
        Process.setproctitle(name)
        $PROGRAM_NAME = name
        $0 = name
      end

      def init_gtk_application(options, &block)
        app_name    = options[:name].nil?       ? "mittens_ui_app" : options[:name]
        height      = options[:height].nil?     ? 600 : options[:height]
        width       = options[:width].nil?      ? 400 : options[:width]
        title       = options[:title].nil?      ? "Mittens App" : options[:title]
        can_resize  = options[:can_resize].nil? ? true : options[:can_resize]

        app_assets_path = File.join(File.expand_path(File.dirname(__FILE__)), "mittens_ui", "assets") + "/"
        default_icon = app_assets_path + "icon.png"
        
        app_icon = options[:icon].nil? ? default_icon : options[:icon]

        set_process_name(app_name)

        gtk_app_name = "org.mittens_ui.#{app_name}"

        app = Gtk::Application.new(gtk_app_name, :flags_none)

        app.signal_connect("activate") do |application|
          $app_window = Gtk::ApplicationWindow.new(application)
          scrolled_window = Gtk::ScrolledWindow.new
          $vertical_box = Gtk::Box.new(:vertical, 10)
          scrolled_window.add($vertical_box)
          $app_window.add(scrolled_window)
          yield($app_window, $vertical_box)
          $app_window.set_size_request(width, height)
          $app_window.set_title(title)
          $app_window.set_resizable(can_resize)
          $app_window.set_icon_from_file(app_icon)
          $app_window.show_all
        end

        app.run
      end
    end
  end
end
