require "mittens_ui/helpers"

module MittensUi
  module Widgets
    class Core    
      include Helpers

      # All MittenUi::Widgets::* classes should inherit from this base class.

      def initialize(widget)
        @core_widget = widget
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
end