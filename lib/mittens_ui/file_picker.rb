require_relative "./core"

module MittensUi
  class FilePicker
    attr_reader :path

    def initialize(options = {})
      @path = nil
      parent_window = MittensUi::Application.window
      dialog_options = {
        title: "Select File",
        parent: parent_window,
        action: options[:action] || :open,
        buttons: [
          [Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT],
          [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]
        ]
      }.freeze
      
      @dialog = Gtk::FileChooserDialog.new(dialog_options)
      if @dialog.run == :accept
        @path = @dialog.filename
      end
      @dialog.destroy
    end
  end
end