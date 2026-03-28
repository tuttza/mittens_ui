require_relative "./core"

module MittensUi
  class Notify < Core
    def initialize(msg, options = {})
      @activate_timer = options[:timer] || true
      @notify_bar = Gtk::InfoBar.new
      @notify_bar.set_show_close_button(true)
      msg_label = Gtk::Label.new(msg)
      @notify_bar.message_type = set_msg_type(options)
      @notify_bar.content_area.pack_start(msg_label)
      setup_close_notification
      super(@notify_bar, options)
    end

    def render
      layout = MittensUi::Application.layout
      layout.add_at_top(@notify_bar)
      @notify_bar.show_all
      trigger_notify_timer if @activate_timer
      self
    end

    private

    def set_msg_type(options = {})
      case options[:type]
      when :question then Gtk::MessageType::QUESTION
      when :error    then Gtk::MessageType::ERROR
      when :info     then Gtk::MessageType::INFO
      else                Gtk::MessageType::INFO
      end
    end

    def trigger_notify_timer
      Thread.new {
        sleep 8
        @notify_bar.hide if @notify_bar.visible?
      }
    end

    def setup_close_notification
      @notify_bar.signal_connect("response") do |info_bar, response_id|
        @notify_bar.hide if response_id == Gtk::ResponseType::CLOSE
      end
    end
  end
end