require_relative "./core"

module MittensUi
  # A group of mutually exclusive radio button options.
  # Wraps {https://docs.gtk.org/gtk3/class.RadioButton.html Gtk::RadioButton}
  # and manages grouping automatically so only one option can be selected at a time.
  # The buttons are arranged horizontally by default, or vertically with +:vertical+ layout.
  #
  # @example Basic radio button group
  #   rb = MittensUi::RadioButton.new(
  #     options: ["Small", "Medium", "Large"],
  #     default: "Medium"
  #   )
  #   puts rb.selected  # => "Medium"
  #
  # @example Vertical layout
  #   rb = MittensUi::RadioButton.new(
  #     options: ["Red", "Green", "Blue"],
  #     layout: :vertical
  #   )
  #
  # @example Reacting to selection change
  #   rb = MittensUi::RadioButton.new(options: ["Yes", "No"])
  #   rb.on_change do |value|
  #     puts "Selected: #{value}"
  #   end
  class RadioButton < Core

    # Creates a new RadioButton group.
    #
    # @param options [Hash] configuration options
    # @option options [Array<String>] :options ([]) the list of option labels
    # @option options [String, nil] :default (nil) the initially selected option.
    #   If nil, the first option is selected by default.
    # @option options [Symbol] :layout (:horizontal) the layout direction.
    #   Accepted values are +:horizontal+ and +:vertical+
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(options = {})
      @option_labels = options[:options] || []
      @default       = options[:default] || @option_labels.first
      @layout        = options[:layout]  || :horizontal
      @on_change     = nil
      @buttons       = {}

      raise ArgumentError, "RadioButton requires at least one option" if @option_labels.empty?

      @container = Gtk::Box.new(@layout, 8)
      init_buttons

      super(@container, options)
    end

    # Returns the currently selected option label.
    #
    # @return [String, nil] the selected option, or nil if none selected
    # @example
    #   rb.selected  # => "Medium"
    def selected
      @buttons.find { |_label, btn| btn.active? }&.first
    end

    # Programmatically selects an option by label.
    # Has no effect if the label does not exist in the group.
    #
    # @param label [String] the option label to select
    # @return [void]
    # @example
    #   rb.select("Large")
    def select(label)
      @buttons[label]&.set_active(true)
    end

    # Connects a block to the selection change event.
    # The block is called whenever the user selects a different option.
    #
    # @yield [value] called when the selected option changes
    # @yieldparam value [String] the newly selected option label
    # @return [void]
    # @example
    #   rb.on_change do |value|
    #     puts "User selected: #{value}"
    #   end
    def on_change(&block)
      @on_change = block
    end

    # Returns all option labels in the group.
    #
    # @return [Array<String>] the list of option labels
    def options
      @option_labels
    end

    private

    # Initializes the Gtk::RadioButton widgets, groups them together,
    # sets the default selection, and wires up change callbacks.
    #
    # @return [void]
    def init_buttons
      group = nil

      @option_labels.each do |label|
        btn = if group.nil?
          Gtk::RadioButton.new(label: label)
        else
          Gtk::RadioButton.new(member: group, label: label)
        end

        group ||= btn

        btn.set_active(label == @default)

        btn.signal_connect("toggled") do |b|
          if b.active?
            @on_change&.call(label)
          end
        end

        @buttons[label] = btn
        @container.pack_start(btn, expand: false, fill: false, padding: 0)
      end
    end
  end
end