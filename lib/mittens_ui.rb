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
require "mittens_ui/store"
require "mittens_ui/radiobutton"
require "mittens_ui/colorpicker"
require "mittens_ui/knob"
require "gtk3"

module MittensUi
  # Base error class for all MittensUi errors.
  class Error < StandardError; end

  # The main application class for MittensUi.
  # Responsible for bootstrapping the GTK application, managing the window,
  # layout, and providing access to shared application state like the
  # persistent store.
  #
  # @example Basic application setup
  #   MittensUi::Application.Window(name: "my_app", title: "My App", width: 400, height: 600) do
  #     MittensUi::Label.new("Hello World!")
  #     MittensUi::Button.new(title: "Click Me")
  #   end
  #
  # @example Accessing the persistent store
  #   MittensUi::Application.store.set(:theme, "dark")
  #   MittensUi::Application.store.get(:theme)  # => "dark"
  #
  # @example Exiting the application
  #   MittensUi::Application.exit { puts "Goodbye!" }
  class Application
    class << self
      # The underlying Gtk::Application instance.
      # @return [Gtk::Application]
      attr_reader :gtk_app

      # The layout manager responsible for placing widgets in the window.
      # @return [MittensUi::LayoutManager]
      attr_reader :layout

      # The main application window.
      # @return [Gtk::ApplicationWindow]
      attr_reader :window

      # The GTK application ID in reverse-domain format.
      # @return [String] e.g. "org.mittens_ui.my_app"
      attr_reader :app_id

      # Pushes a container onto the container stack, making it the active
      # container for widget rendering. Any widgets created after this call
      # will render into this container instead of the main layout grid.
      # Used internally by {MittensUi::HBox} to support block-style widget creation
      # and nested HBox instances.
      #
      # @param container [MittensUi::HBox] the container to push onto the stack
      # @return [Array] the updated container stack
      # @see pop_container
      # @see current_container
      def push_container(container)
        @container_stack ||= []
        @container_stack.push(container)
      end

      # Pops the most recently pushed container off the stack, restoring
      # the previous container (or the main layout if the stack is empty)
      # as the active render target. Called automatically by {MittensUi::HBox}
      # after its block finishes evaluating.
      #
      # @return [MittensUi::HBox, nil] the container that was removed, or nil if stack was empty
      # @see push_container
      # @see current_container
      def pop_container
        @container_stack ||= []
        @container_stack.pop
      end

      # Returns the currently active container, or nil if no container is active.
      # When non-nil, {MittensUi::Core#render} will add newly created widgets
      # to this container instead of the main layout grid.
      # Supports nested {MittensUi::HBox} instances by always returning
      # the innermost active container.
      #
      # @return [MittensUi::HBox, nil] the current active container, or nil
      # @see push_container
      # @see pop_container
      def current_container
        @container_stack&.last
      end

      # Applies the theme based on the given mode.
      # Respects the system preference when set to +:system+.
      #
      # @param theme [Symbol] +:dark+, +:light+, or +:system+
      # @return [void]
      def apply_theme(theme)
        settings = Gtk::Settings.default
        case theme
        when :dark
          settings.gtk_application_prefer_dark_theme = true
        when :light
          settings.gtk_application_prefer_dark_theme = false
        when :system
          # respect whatever the system/desktop environment has set
          # GTK will use the system preference by default so we don't
          # override it here
          nil
        end
        @current_theme = theme
      end

      # Returns the current theme.
      #
      # @return [Symbol] +:dark+, +:light+, or +:system+
      def current_theme
        @current_theme || :system
      end

      # Toggles between dark and light mode at runtime.
      #
      # @return [void]
      # @example
      #   btn.click { MittensUi::Application.toggle_theme }
      def toggle_theme
        new_theme = current_theme == :dark ? :light : :dark
        apply_theme(new_theme)
      end

      # Creates and runs the main application window.
      # This is the entry point for every MittensUi application.
      # The block is evaluated inside the GTK activate signal, so all
      # widget creation should happen inside it.
      #
      # @param options [Hash] window configuration options
      # @option options [String] :name ("mittens_ui_app") the app identifier,
      #   used as the process name and store filename
      # @option options [Integer] :width (400) the window width in pixels
      # @option options [Integer] :height (600) the window height in pixels
      # @option options [String] :title ("Mittens App") the window title
      # @option options [Boolean] :can_resize (true) whether the window is resizable
      # @option options [String] :icon path to a custom window icon file
      # @yield [window] the GTK application window
      # @yieldparam window [Gtk::ApplicationWindow] the main window instance
      # @return [void]
      # @example
      #   MittensUi::Application.Window(name: "contacts", title: "Contacts", width: 570, height: 615) do
      #     MittensUi::Label.new("Welcome!")
      #   end
      def Window(options = {}, &block)
        init_gtk_application(options, &block)
      end

      # Exits the application cleanly, optionally running a block before quitting.
      # If the block raises an error, the application exits with code 1.
      # Always quits the GTK application loop via {#gtk_app}.
      #
      # @yield optional block to run before exiting
      # @return [void]
      # @example
      #   MittensUi::Application.exit { puts "Saving data..." }
      def exit(&block)
        begin
          yield if block_given?
        rescue => _error
          puts("Exiting with: #{_error}")
          Kernel.exit(1)
        ensure
          gtk_app.quit if gtk_app
        end
      end

      # Returns the persistent store for this application.
      # The store is lazily initialized on first access and scoped
      # to the application name.
      #
      # @return [MittensUi::Store] the application store
      # @example
      #   MittensUi::Application.store.set(:last_user, "John")
      #   MittensUi::Application.store.get(:last_user)  # => "John"
      def store
        @store ||= Store.new(@app_id)
      end

      private

      # Sets the OS process name to the given app name.
      # Affects how the process appears in system tools like +top+ and +ps+.
      #
      # @param name [String] the process name to set
      # @return [void]
      def set_process_name(name)
        Process.setproctitle(name)
        $PROGRAM_NAME = name
        $0 = name
      end

      # Bootstraps the GTK application, sets up the window, layout manager,
      # and scrollable container, then runs the GTK main loop.
      #
      # @param options [Hash] see {.Window} for options
      # @yield [window] the GTK application window
      # @return [void]
      def init_gtk_application(options, &block)
        app_name        = options[:name]       || "mittens_ui_app"
        height          = options[:height]     || 600
        width           = options[:width]      || 400
        title           = options[:title]      || "Mittens App"
        theme           = options[:theme]      || :system
        can_resize      = options.fetch(:can_resize, true)
        app_assets_path = File.join(File.expand_path(File.dirname(__FILE__)), "mittens_ui", "assets") + "/"
        app_icon        = options[:icon] || app_assets_path + "icon.png"

        set_process_name(app_name)

        @app_id  = "org.mittens_ui.#{app_name}"
        @gtk_app = Gtk::Application.new(@app_id, :flags_none)

        @gtk_app.signal_connect("activate") do |application|
          apply_theme(theme)
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
