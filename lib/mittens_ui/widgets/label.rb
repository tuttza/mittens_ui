require_relative "./core"

module MittensUi
  module Widgets
    class Label < Core
      def initialize(text, options)
        if text.nil? || text == "" || text == " "
          text = "Label"
        end

        @label = Gtk::Label.new(text)

        set_margin_from_opts_for(@label, options)

        $vertical_box.pack_start(@label)

        super(@label)
      end
    end
  end
end