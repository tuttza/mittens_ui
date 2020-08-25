require "mittens_ui/version"

require "mittens_ui/layouts/grid"
require "mittens_ui/layouts/stack"
require "mittens_ui/layouts/box"

require "mittens_ui/widgets/alert"
require "mittens_ui/widgets/label"
require "mittens_ui/widgets/button"
require "mittens_ui/widgets/textbox"

require "gtk3"

module MittensUi
  class Error < StandardError; end

  def self.Alert(window, message, options={})
    MittensUi::Widgets::Alert.init(window, message, options)
  end

  def self.Label(text, options)
    MittensUi::Widgets::Label.init(text, options)
  end

  def self.Textbox(options, &block)
    textbox = nil 
    
    unless block_given?
      textbox = MittensUi::Widgets::Textbox.init(options, nil)
    else
      textbox = MittensUi::Widgets::Textbox.init(options, block = Proc.new)
    end

    if block_given?
      block.call textbox
    else
      return textbox
    end 
  end

  def self.Box(window, &block)
    raise Error.new("A MittensUi::Box must be passed a block.") unless block_given?
    MittensUi::Layouts::Box.init(window, block = Proc.new)
  end

  def self.Grid(window, &block) 
    raise Error.new("A Grid must be passed a block.") unless block_given?
    MittensUi::Layouts::Grid.init(window, block = Proc.new)
  end

  def self.Stack(window, &block)
    raise Error.new("A Stack must be passed a block.") unless block_given?
    MittensUi::Layouts::Stack.init(window, block = Proc.new)
  end

  def self.Button(options, &block)
    raise Error.new("Button must be passed a block.") unless block_given?
    MittensUi::Widgets::Button.init(options, block = Proc.new)
  end

  class Application
    class << self
      def Window(options = {}, &block)  
        init_gtk_toplevel_window(options, &block)
        block.call(@@GTK_WINDOW)
        @@GTK_WINDOW.show_all
        Gtk.main
      end
  
      def init_gtk_toplevel_window(options)
        @@GTK_WINDOW = Gtk::Window.new(:toplevel)
  
        height      = options[:height].nil? ? 600 : options[:height]
        width       = options[:width].nil? ? 400 : options[:width]
        title       = options[:title].nil? ? "Mittens App" : options[:title]
        can_resize  = options[:can_resize].nil? ? true : options[:can_resize]
        
        @@GTK_WINDOW.set_size_request(width, height)
        @@GTK_WINDOW.set_title(title)
        @@GTK_WINDOW.set_resizable(can_resize)
        @@GTK_WINDOW.set_window_position(:center_always)

        @@GTK_WINDOW.signal_connect("delete-event") { |_widget| Gtk.main_quit }
      end
      
    end
  end
end
