module MittensUi
	module Dialogs
    class File
      attr_reader :path

      def initialize(options={})
        @path = ""
        
        dialog_options = {
          title: "Select File",
          parent: $app_window,
          action: options[:action] || :open,
          buttons: [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT], [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]]
        }.freeze
        
        dialog = Gtk::FileChooserDialog.new(dialog_options)
        
        if dialog.run == :accept
          @path = dialog.filename
        end

        dialog.destroy
      end
    end
  end
end