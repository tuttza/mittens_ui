require "mittens_ui/helpers"

module MittensUi
  class Core
    include Helpers
    attr_reader :core_widget

    def initialize(widget, options = {})
      @core_widget = widget
      @width = options[:width] || :full
      set_margin_from_opts_for(@core_widget, options)
      render
    end

    def show
      @core_widget.show_all
    end

    def hidden?
      @core_widget.visible?
    end

    def hide
      return if @core_widget.nil?
      @core_widget.hide
    end

    def remove
      MittensUi::Application.layout.remove(@core_widget)
    end

    def render
      MittensUi::Application.layout.add(@core_widget, width: @width)
    end
  end
end