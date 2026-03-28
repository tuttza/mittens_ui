require "mittens_ui/version"
require "mittens_ui/layout_manager"
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
require "mittens_ui/notify"
require "gtk3"

module MittensUi
  class Error < StandardError; end

  class Application
    class << self
      attr_reader :gtk_app, :layout, :window

      def Window(options = {}, &block)
        init_gtk_application(options, &block)
      end

      def exit(&block)
        begin
          yield if block_given?
        rescue => _error
          print("Exiting with: #{_error}")
          Kernel.exit(1)
        ensure
          gtk_app.quit if gtk_app
        end
      end

      private

      def set_process_name(name)
        Process.setproctitle(name)
        $PROGRAM_NAME = name
        $0 = name
      end

      def init_gtk_application(options, &block)
        app_name        = options[:name]       || "mittens_ui_app"
        height          = options[:height]     || 600
        width           = options[:width]      || 400
        title           = options[:title]      || "Mittens App"
        can_resize      = options.fetch(:can_resize, true)
        app_assets_path = File.join(File.expand_path(File.dirname(__FILE__)), "mittens_ui", "assets") + "/"
        app_icon        = options[:icon] || app_assets_path + "icon.png"

        set_process_name(app_name)

        @gtk_app = Gtk::Application.new("org.mittens_ui.#{app_name}", :flags_none)

        @gtk_app.signal_connect("activate") do |application|
          @window = Gtk::ApplicationWindow.new(application)
          scrolled_window = Gtk::ScrolledWindow.new
          vertical_box = Gtk::Box.new(:vertical, 10)
          @layout = LayoutManager.new(vertical_box)
          scrolled_window.add(vertical_box)
          @window.add(scrolled_window)
          yield(@window)
          @window.set_size_request(width, height)
          @window.set_title(title)
          @window.set_resizable(can_resize)
          @window.set_icon_from_file(app_icon)
          @window.show_all
        end

        @gtk_app.run
      end
    end
  end
end