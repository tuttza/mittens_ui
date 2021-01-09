require_relative "./core"

module MittensUi
  module Widgets
    class Checkbox < Core
      attr_accessor :value
      
      def initialize(options={})
				label = options[:label] || "Checkbox"

				@value = nil
        @checkbox = Gtk::CheckButton.new(label)

        set_margin_from_opts_for(@checkbox, options)

        $vertical_box.pack_start(@checkbox)

        super(@checkbox)
      end

      def toggle
        @checkbox.signal_connect "toggled" do
          yield
        end
      end
    end
  end
end
