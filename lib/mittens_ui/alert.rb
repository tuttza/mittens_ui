module MittensUi
  class Alert
    def initialize(message, options={})
      dialog_options = {
        title: options[:title] || "Alert",
        parent: $app_window,
        flags: [:modal, :destroy_with_parent],
        :buttons => [[Gtk::Stock::OK, :none]]
      }.freeze

      @dialog = Gtk::Dialog.new(dialog_options)
      @dialog.set_transient_for($app_window)
      @dialog.set_default_width(420)
      @dialog.set_default_height(200)
      @dialog.set_modal(true)
      @dialog.set_resizable(false)

      message_label = Gtk::Label.new(message)
      message_label.set_margin_top(36)

      dialog_box = @dialog.content_area
      dialog_box.add(message_label)
    end

    def render
      @dialog.show_all
      response = @dialog.run
      response == :none ? @dialog.destroy : @dialog.destroy
    end

  end
end

