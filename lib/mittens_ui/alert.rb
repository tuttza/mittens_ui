# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A modal alert dialog that displays a message and an OK button.
  # Wraps {https://docs.gtk.org/gtk4/class.AlertDialog.html Gtk::AlertDialog}.
  # Opens immediately on instantiation and blocks until dismissed.
  # Optionally accepts a block that runs after the user closes the dialog.
  #
  # @example Basic alert
  #   MittensUi::Alert.new("Something happened!")
  #
  # @example With custom title
  #   MittensUi::Alert.new("File saved.", title: "Success")
  #
  # @example With block
  #   MittensUi::Alert.new("Are you sure?") do
  #     puts "User acknowledged"
  #   end
  class Alert

    # Creates and immediately displays an alert dialog.
    #
    # @param message [String] the message to display
    # @param options [Hash] configuration options
    # @option options [String] :title ("Alert") the dialog window title
    # @yield optional block called after the user dismisses the dialog
    def initialize(message, options = {}, &block)
      title = options[:title] || 'Alert'
      open_dialog(message, title, &block)
    end

    private

    # Opens the alert dialog using Gtk::AlertDialog.
    #
    # @param message [String] the message to display
    # @param title [String] the dialog title
    # @return [void]
    def open_dialog(message, title, &block)
      parent = MittensUi::Application.window

      dialog = Gtk::AlertDialog.new
      dialog.message = title
      dialog.detail  = message
      dialog.buttons = ['Ok']

      dialog.choose(parent, nil) do |_source, result|
        begin
          dialog.choose_finish(result)
        rescue _error
          # user dismissed
        end
        block&.call
      end
    end
  end
end
