# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A simple wrapper around a GTK4::Label for use with MittensUi::Core.
  #
  # This class ensures the provided text is non-empty and initializes a GTK4
  # label widget, then delegates common setup to MittensUi::Core.
  #
  # Examples:
  #
  #   label = MittensUi::Label.new("Hello")
  #   label = MittensUi::Label.new(nil) # => uses "Label"
  #
  # @example Passing options to Core
  #   MittensUi::Label.new("Hi", expand: true, margin: 8)
  #
  # @see MittensUi::Core
  class Label < Core
    # Create a new Label wrapper.
    #
    # @param text [String, nil] The label text. If nil or blank, defaults to "Label".
    # @param options [Hash] Options forwarded to MittensUi::Core (e.g., layout/ styling keys).
    # @option options [Integer] :margin Margin around the widget (optional).
    # @option options [Boolean] :expand Whether the widget should expand (optional).
    #
    # @return [MittensUi::Label] the wrapper instance
    def initialize(text, options = {})
      text = 'Label' if text.nil? || text.to_s.strip.empty?

      gtk_label = Gtk::Label.new(text)
      super(gtk_label, options)
    end
  end
end
