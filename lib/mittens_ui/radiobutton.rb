# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A group of mutually exclusive radio button options.
  # Wraps {https://docs.gtk.org/gtk4/class.CheckButton.html Gtk::CheckButton}
  # with group linking so only one option can be selected at a time.
  # GTK4 removed Gtk::RadioButton — CheckButton with a group is the replacement.
  #
  # @example Basic radio button group
  #   rb = MittensUi::RadioButton.new(
  #     options: ['Small', 'Medium', 'Large'],
  #     default: 'Medium'
  #   )
  #   puts rb.selected  # => "Medium"
  #
  # @example Vertical layout
  #   rb = MittensUi::RadioButton.new(
  #     options: ['Red', 'Green', 'Blue'],
  #     layout: :vertical
  #   )
  #
  # @example Reacting to selection change
  #   rb = MittensUi::RadioButton.new(options: ['Yes', 'No'])
  #   rb.on_change { |value| puts "Selected: #{value}" }
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

      raise ArgumentError, 'RadioButton requires at least one option' if @option_labels.empty?

      @container = Gtk::Box.new(@layout, 8)
      init_buttons
      super(@container, options)
    end

    # Returns the currently selected option label.
    #
    # @return [String, nil] the selected option, or nil if none selected
    def selected
      @buttons.find { |_label, btn| btn.active? }&.first
    end

    # Programmatically selects an option by label.
    #
    # @param label [String] the option label to select
    # @return [void]
    def select(label)
      @buttons[label]&.set_active(true)
    end

    # Connects a block to the selection change event.
    #
    # @yield [value] called when the selected option changes
    # @yieldparam value [String] the newly selected option label
    # @return [void]
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

    # Initializes the CheckButton widgets and links them into a group.
    # GTK4 uses Gtk::CheckButton#group= instead of Gtk::RadioButton member.
    #
    # @return [void]
    def init_buttons
      first_button = nil

      @option_labels.each do |label|
        btn = Gtk::CheckButton.new(label)

        if first_button.nil?
          first_button = btn
        else
          btn.group = first_button
        end

        btn.set_active(label == @default)

        btn.signal_connect('toggled') do |b|
          @on_change&.call(label) if b.active?
        end

        @buttons[label] = btn
        @container.append(btn)
      end
    end
  end
end
