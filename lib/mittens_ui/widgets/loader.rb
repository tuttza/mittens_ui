require_relative "./core"

module MittensUi
  module Widgets
    class Loader < Core
      def initialize(options={})
        @spinner = Gtk::Spinner.new

        @processing = false

        set_margin_from_opts_for(@spinner, options)

        $vertical_box.pack_end(@spinner)

        super(@spinner)

        self.hide
      end

      def start(&block)
        return if @processing

        return if @worker_thread && @worker_thread.alive?

        self.show

        @spinner.start

        @worker_thread = Thread.new { yield; self.remove; @processing = true }
      end

    end
  end
end
