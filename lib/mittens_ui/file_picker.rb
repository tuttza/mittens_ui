# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A file picker dialog that allows the user to select a file.
  # Wraps {https://docs.gtk.org/gtk4/class.FileDialog.html Gtk::FileDialog}.
  # Opens immediately on instantiation. The selected path is accessible
  # via {#path} after the dialog closes.
  #
  # @example Basic usage
  #   picker = MittensUi::FilePicker.new
  #   puts picker.path  # => "/home/user/file.txt" or nil if cancelled
  #
  # @example With block
  #   MittensUi::FilePicker.new do |path|
  #     puts "Selected: #{path}" if path
  #   end
  class FilePicker
    attr_reader :path

    # Creates a new FilePicker dialog and opens it immediately.
    #
    # @param options [Hash] configuration options
    # @option options [String] :title ("Select File") the dialog title
    # @yield [path] optional block called with the selected path, or nil if cancelled
    # @yieldparam path [String, nil] the selected file path
    def initialize(options = {}, &block)
      @path = nil
      open_dialog(options, &block)
    end

    private

    # Opens the file dialog using GTK4 Gtk::FileDialog.
    #
    # @param options [Hash] configuration options
    # @return [void]
    def open_dialog(options, &block)
      parent = MittensUi::Application.window

      dialog = Gtk::FileDialog.new
      dialog.title = options.fetch(:title, 'Select File')
      dialog.modal = true

      dialog.open(parent, nil) do |_source, result|
        begin
          file  = dialog.open_finish(result)
          @path = file.path if file
        rescue
          # user cancelled
          @path = nil
        end
        block&.call(@path)
      end
    end
  end
end
