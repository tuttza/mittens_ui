require_relative "./core"

module MittensUi
  # A single-line or multiline text input widget.
  # In single-line mode (default), wraps {https://docs.gtk.org/gtk3/class.Entry.html Gtk::Entry}.
  # In multiline mode, wraps {https://docs.gtk.org/gtk3/class.TextView.html Gtk::TextView}
  # inside a {https://docs.gtk.org/gtk3/class.ScrolledWindow.html Gtk::ScrolledWindow}.
  #
  # @example Single-line textbox
  #   tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Enter name...")
  #   puts tb.text
  #
  # @example Password field
  #   tb = MittensUi::Textbox.new(password: true)
  #
  # @example Multiline textbox
  #   tb = MittensUi::Textbox.new(multiline: true, width: :full)
  #   puts tb.text
  #
  # @example Text completion
  #   tb = MittensUi::Textbox.new(can_edit: true)
  #   tb.enable_text_completion(["Apple", "Banana", "Cherry"])
  class Textbox < Core

    # Creates a new Textbox widget.
    #
    # @param options [Hash] configuration options
    # @option options [Boolean] :can_edit (true) whether the text is editable
    # @option options [Boolean] :multiline (false) when true, renders a scrollable
    #   multiline text area instead of a single-line input
    # @option options [Integer] :max_length (200) maximum character length.
    #   Only applies in single-line mode.
    # @option options [Boolean] :password (false) when true, obscures the input text.
    #   Only applies in single-line mode.
    # @option options [String] :placeholder ("") placeholder text shown when empty.
    #   Only applies in single-line mode.
    # @option options [Integer] :height (100) height of the scrolled window in pixels.
    #   Only applies in multiline mode.
    # @option options [Symbol] :width (:full) column width in the layout grid.
    #   Accepted values are +:full+, +:half+, +:third+, +:quarter+
    # @option options [Boolean] :defer_render (false) when true, skips auto-rendering
    #   into the layout. Use when passing to a container like {HBox}.
    def initialize(options = {})
      @multiline = options[:multiline] || false

      if @multiline
        init_multiline(options)
      else
        init_single_line(options)
      end

      super(@gtk_widget, options)
    end

    # Returns the current text content of the widget.
    # Works in both single-line and multiline mode.
    #
    # @return [String] the current text
    # @example
    #   tb = MittensUi::Textbox.new
    #   tb.text  # => ""
    def text
      if @multiline
        @text_buffer.text
      else
        @textbox.text
      end
    end

    # Clears all text from the widget.
    # Works in both single-line and multiline mode.
    #
    # @return [void]
    # @example
    #   tb = MittensUi::Textbox.new
    #   tb.clear
    def clear
      if @multiline
        @text_buffer.text = ""
      else
        @textbox.text = ""
      end
    end

    # Enables autocomplete suggestions for single-line mode.
    # Has no effect in multiline mode.
    #
    # @param data [Array<String>] list of strings to suggest as completions
    # @return [void]
    # @example
    #   tb = MittensUi::Textbox.new(can_edit: true)
    #   tb.enable_text_completion(["Ruby", "Rails", "Rack"])
    def enable_text_completion(data)
      return if @multiline

      completion = Gtk::EntryCompletion.new
      model = Gtk::ListStore.new(String)
      data.each do |value|
        iter = model.append
        iter[0] = value
      end
      completion.model = model
      completion.text_column = 0
      @textbox.completion = completion
    end

    private

    # Initializes the widget in single-line mode using Gtk::Entry.
    #
    # @param options [Hash] see {#initialize} for options
    # @return [void]
    def init_single_line(options)
      @textbox         = Gtk::Entry.new
      can_edit         = options.fetch(:can_edit, true)
      max_length       = options[:max_length]  || 200
      has_password     = options[:password]    || false
      placeholder_text = options[:placeholder] || ""

      @textbox.set_visibility(false) if has_password
      @textbox.set_editable(can_edit)
      @textbox.set_max_length(max_length)
      @textbox.set_placeholder_text(placeholder_text)

      @gtk_widget = @textbox
    end

    # Initializes the widget in multiline mode using Gtk::TextView
    # wrapped in a Gtk::ScrolledWindow.
    #
    # @param options [Hash] see {#initialize} for options
    # @return [void]
    def init_multiline(options)
      can_edit = options.fetch(:can_edit, true)
      height   = options[:height] || 100

      @text_view   = Gtk::TextView.new
      @text_buffer = @text_view.buffer

      @text_view.set_editable(can_edit)
      @text_view.set_wrap_mode(:word_char)
      @text_view.set_accepts_tab(false)

      @scrolled_window = Gtk::ScrolledWindow.new
      @scrolled_window.set_policy(:automatic, :automatic)
      @scrolled_window.min_content_height = height
      @scrolled_window.add(@text_view)

      @gtk_widget = @scrolled_window
    end
  end
end