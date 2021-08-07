require_relative "./core"
require "mittens_ui/helpers"

module MittensUi
  class Button < Core
    include Helpers

    def initialize(options={})
      button_title  = options[:title] || "Button"  

      icon_type = options[:icon] || nil   

      if icon_type
        image = Gtk::Image.new(icon_name: icon_map[icon_type], size: @button)
        @button = Gtk::Button.new
        @button.add(image)
      else
        @button = Gtk::Button.new(label: button_title)
      end

      super(@button, options)
    end

    def enable(answer)
      @button.set_sensitive(answer)
    end

    def click
      @button.signal_connect("clicked") do |button_widget|
        yield(button_widget)
      end
    end

    def render
      $vertical_box.pack_start(@button)
      return self
    end

  end
end
