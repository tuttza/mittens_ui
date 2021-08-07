require_relative "./core"

module MittensUi
  module Widgets
    class Loader < Core
      def initialize(options={})
        @spinner = Gtk::Spinner.new

        @processing = false

        $vertical_box.pack_end(@spinner)

        super(@spinner, options)

        self.hide
      end

      def start(&block)
        return if @processing

        return if @worker_thread && @worker_thread.alive?

        self.show

        @spinner.start

        @worker_thread = Thread.new { yield; self.remove; @processing = true }
      end

      def render
        $vertical_box.pack_end(@spinner)
        return self
      end

    end
  end
end
