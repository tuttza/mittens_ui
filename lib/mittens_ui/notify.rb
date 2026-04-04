# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A dismissible notification widget that displays styled messages with optional auto-hide timer.
  # Supports multiple notification types (error, info, question, default) with distinct styling.
  #
  # @example Basic notification
  #   MittensUi::Notify.new("Operation completed successfully!")
  #
  # @example Error notification without auto-hide
  #   MittensUi::Notify.new("An error occurred", type: :error, timer: false)
  #
  # @example Question notification
  #   MittensUi::Notify.new("Are you sure?", type: :question)
  #
  # @example Info notification with custom timer
  #   notify = MittensUi::Notify.new("Processing...", type: :info)
  #   # Notification auto-hides after 8 seconds
  class Notify < Core
    # Embedded CSS styles for all notification types
    NOTIFICATION_CSS = <<~CSS
      /* Base notification styles */
      .notify-container {
        padding: 12px;
        margin: 6px 10px;
        border-radius: 6px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
      }

      /* Default notification */
      .notify-default {
        background-color: #f0f0f0;
        color: #333333;
        border-left: 4px solid #cccccc;
      }

      /* Error notification */
      .notify-error {
        background-color: #ffebee;
        color: #c62828;
        border-left: 4px solid #ef5350;
      }

      /* Info notification */
      .notify-info {
        background-color: #e3f2fd;
        color: #1565c0;
        border-left: 4px solid #42a5f5;
      }

      /* Question notification */
      .notify-question {
        background-color: #f3e5f5;
        color: #6a1b9a;
        border-left: 4px solid #ab47bc;
      }

      /* Close button styles */
      .notify-close-button {
        min-width: 24px;
        min-height: 24px;
        padding: 0;
        margin: 0 0 0 12px;
        border: none;
        background: none;
        color: inherit;
        font-weight: bold;
        //cursor: pointer;
      }

      .notify-close-button:hover {
        background-color: rgba(0,0,0,0.1);
        border-radius: 12px;
      }
    CSS

    # Creates a new Notify widget with styled notification
    #
    # @param msg [String] the notification message to display
    # @param options [Hash] configuration options
    # @option options [Boolean] :timer (true) when true, automatically hides after 8 seconds
    # @option options [Symbol] :type (:default) notification type (:error, :question, :info, :default)
    # @option options [Symbol] :width (:full) column width in layout grid
    # @option options [Boolean] :defer_render (false) when true, skips auto-rendering
    #
    # @return [Notify] a new Notify instance
    def initialize(msg, options = {})
      @activate_timer = options.fetch(:timer, true)
      @custom_duration = options.fetch(:duration, 8000)

      # Setup CSS provider
      setup_css_provider

      # Root container
      @notify_bar = Gtk::Box.new(:horizontal, 10)
      @notify_bar.add_css_class('notify-container')
      @notify_bar.add_css_class(css_class_for(options))

      # Message label
      msg_label = Gtk::Label.new(msg)
      msg_label.hexpand = true
      msg_label.xalign = 0

      # Close button
      close_button = Gtk::Button.new(label: '✕')
      close_button.add_css_class('notify-close-button')
      close_button.signal_connect('clicked') do
        @notify_bar.visible = false
      end

      @notify_bar.append(msg_label)
      @notify_bar.append(close_button)

      super(@notify_bar, options)
    end

    # Displays the notification in the application layout
    #
    # @return [Notify] returns self for method chaining
    def render
      layout = MittensUi::Application.layout
      layout.add_at_top(@notify_bar)
      @notify_bar.visible = true
      trigger_notify_timer if @activate_timer
      self
    end

    private

    # Sets up the CSS provider with embedded styles
    #
    # @return [void]
    def setup_css_provider
      @css_provider ||= begin
        provider = Gtk::CssProvider.new
        provider.load_from_data(NOTIFICATION_CSS)
        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default,
          provider,
          Gtk::StyleProvider::PRIORITY_APPLICATION
        )
        provider
      end
    end

    # Determines CSS class based on notification type
    #
    # @param options [Hash] configuration options
    # @return [String] CSS class name
    def css_class_for(options = {})
      case options[:type]
      when :error    then 'notify-error'
      when :question then 'notify-question'
      when :info     then 'notify-info'
      else                'notify-default'
      end
    end

    # Sets up auto-hide timer for notification
    #
    # @return [void]
    def trigger_notify_timer
      GLib::Timeout.add(@custom_duration) do
        @notify_bar.visible = false if @notify_bar.visible?
        false
      end
    end
  end
end
