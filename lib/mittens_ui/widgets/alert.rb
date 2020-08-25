module MittensUi
  module Widgets
    class Alert
      class << self
        def init(window, message, options)
          dialog_options = {
            title: "Alert",
            parent: window,
            flags: [:modal, :destroy_with_parent],
            :buttons => [["_OK", :none]]
          }.freeze

          alert_dialog = Gtk::Dialog.new(dialog_options)
          alert_dialog.set_transient_for(window)
          alert_dialog.set_default_width(420)
          alert_dialog.set_default_height(200)

          message_label = Gtk::Label.new(message)
          dialog_box = alert_dialog.content_area
          dialog_box.add(message_label)
          
          alert_dialog.show_all
        
          response = alert_dialog.run

          response == :none ? alert_dialog.destroy : alert_dialog.destroy

        end
      end
    end
  end
end