require_relative "./core"

module MittensUi
  module Widgets
    class Button < Core
      def initialize(options={})
        button_title  = options[:title] || "Button"

        @button = Gtk::Button.new(label: button_title)

        set_margin_from_opts_for(@button, options)

        $vertical_box.pack_start(@button)

        super(@button)
      end

      def click
        @button.signal_connect("clicked") do |button_widget|
          yield(button_widget)
        end
      end
    end
  end
end
