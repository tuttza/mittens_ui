require_relative "./core"

module MittensUi
  module Widgets
    class Loader < Core
      def initialize(options={})
        @spinner = Gtk::Spinner.new

        @spinner.start

        set_margin_from_opts_for(@spinner, options)

        $vertical_box.pack_start(@spinner)

        super(@spinner)
      end

    end
  end
end
