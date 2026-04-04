# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A loading spinner widget that displays an animated indicator during asynchronous operations.
  # Wraps {https://docs.gtk.org/gtk4/class.Spinner.html Gtk::Spinner} and manages a background
  # worker thread to prevent blocking the UI during long-running tasks.
  #
  # The spinner is hidden by default and automatically shown/hidden based on processing state.
  # Only one worker thread can run at a time; subsequent calls to {#start} while a thread
  # is already running are safely ignored.
  #
  # @example Basic usage
  #   loader = MittensUi::Loader.new
  #   loader.start do
  #     sleep 2  # Simulate long-running work
  #     puts "Work complete!"
  #   end
  #
  # @example With custom width
  #   loader = MittensUi::Loader.new(width: :half)
  #   loader.start { perform_database_query }
  class Loader < Core

    # Creates a new Loader widget with a spinner animation.
    #
    # The spinner is initialized in a hidden state. Call {#start} to begin
    # displaying the animation and executing a background task.
    #
    # @param options [Hash] configuration options
    # @option options [Symbol] :width (:full) column width in the layout grid.
    #   Accepted values are +:full+, +:half+, +:third+, +:quarter+
    # @option options [Boolean] :defer_render (false) when true, skips auto-rendering
    #   into the layout. Use when passing to a container like {HBox}.
    # @return [Loader] a new Loader instance
    def initialize(options = {})
      @spinner = Gtk::Spinner.new
      @processing = false
      super(@spinner, options)
      @spinner.visible = false
    end

    # Starts the spinner animation and executes a block in a background worker thread.
    #
    # The spinner is displayed while the block executes, then automatically hidden
    # when the block completes. If a worker thread is already running, this method
    # safely returns without starting a new thread.
    #
    # @param block [Proc] the work to execute in the background. Exceptions raised
    #   in the block will terminate the thread; consider wrapping critical code
    #   in rescue blocks if needed.
    # @return [void]
    #
    # @example Simple background task
    #   loader = MittensUi::Loader.new
    #   loader.start do
    #     result = expensive_calculation
    #     puts "Done: #{result}"
    #   end
    #
    # @example With error handling
    #   loader.start do
    #     begin
    #       data = fetch_from_api
    #     rescue StandardError => e
    #       puts "Error: #{e.message}"
    #     end
    #   end
    def start(&block)
      return if @processing

      return if @worker_thread&.alive?

      @processing = true
      @spinner.visible = true
      @spinner.start
      @worker_thread = Thread.new do
        block.call
        @processing = false
        @spinner.stop
        @spinner.visible = false
      end
    end
  end
end
