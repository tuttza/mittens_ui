require "mittens_ui/helpers"

module MittensUi
  class Core    
    include Helpers

    attr_reader :core_widget

    # All MittenUi::Widgets::* classes should inherit from this base class.

    def initialize(widget, options={})
      # core_widget is the Raw Gtk::Widget*
      @core_widget = widget
      set_margin_from_opts_for(@core_widget, options)
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
      $vertical_box.remove(@core_widget)
    end
  end
end
