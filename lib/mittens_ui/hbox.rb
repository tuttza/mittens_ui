require_relative "./core"
require "mittens_ui/helpers"

module MittensUi
  class HBox < Core
    include Helpers

    def initialize(widgets, options = {})
      box_spacing = options[:spacing] || 6
      @box = Gtk::Box.new(:horizontal, box_spacing)
      set_margin_from_opts_for(@box, options)
      widgets.each do |w|
        w.remove if w.respond_to?(:remove) && !options[:defer_render]
        attach(w.core_widget)
      end
      super(@box, options)
    end

    def remove
      return if @box.nil?
      MittensUi::Application.layout.remove(@box)
    end

    private

    def attach(widget, position: :start, expand: true, fill: true, padding: 0)
      opts = { expand: expand, fill: fill, padding: padding }
      case position
      when :end then @box.pack_end(widget, opts)
      else           @box.pack_start(widget, opts)
      end
    end
  end
end