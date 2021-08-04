require_relative "./core"

module MittensUi
  module Widgets
    class Button < Core
      def initialize(options={})
        button_title  = options[:title] || "Button"

        @button = Gtk::Button.new(label: button_title)

        $vertical_box.pack_start(@button)

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
    end
  end
end
