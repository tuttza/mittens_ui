require_relative "./core"

module MittensUi
  class Loader < Core
    def initialize(options = {})
      @spinner = Gtk::Spinner.new
      @processing = false
      super(@spinner, options)
      self.hide
    end

    def start(&block)
      return if @processing
      return if @worker_thread && @worker_thread.alive?
      @processing = true
      self.show
      @spinner.start
      @worker_thread = Thread.new do
        yield
        @processing = false
        @spinner.stop
        self.hide
      end
    end
  end
end