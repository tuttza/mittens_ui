require_relative "./core"

module MittensUi
  class Alert
    def initialize(message, options = {})
      parent_window = MittensUi::Application.window
      dialog_options = {
        title: options[:title] || "Alert",
        parent: parent_window,
        flags: [:modal, :destroy_with_parent],
        buttons: [[Gtk::Stock::OK, :none]]
      }.freeze
      @alert_dialog = Gtk::Dialog.new(dialog_options)
      @alert_dialog.set_transient_for(parent_window)
      @alert_dialog.set_default_width(420)
      @alert_dialog.set_default_height(200)
      @alert_dialog.set_modal(true)
      @alert_dialog.set_resizable(false)
      message_label = Gtk::Label.new(message)
      message_label.set_margin_top(36)
      @alert_dialog.content_area.add(message_label)
      @alert_dialog.show_all
      @alert_dialog.run
      @alert_dialog.destroy
    end
  end
end