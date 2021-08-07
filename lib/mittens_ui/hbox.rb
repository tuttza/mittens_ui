require "mittens_ui/helpers"

module MittensUi
  class HBox      
    include Helpers

    def initialize(widgets, options={})
      box_spacing = options[:spacing].nil? ? 6 : options[:spacing]
      
      @box = Gtk::Box.new(:horizontal, box_spacing)

      set_margin_from_opts_for(@box, options)
      
      widgets.each do |w| 
        # We need to remove the widget from the global $vertical_box before hand
        # otherwise it won't render the widgets properly since they are already in another container.
        w.remove
        self.attach(w.core_widget, { position: :start }) 
      end
    end

    def remove
      return if @box.nil?
      @box.destroy
    end

    def render
      $vertical_box.pack_start(@box)
      return self
    end

    private

    def attach(widget, options={})
      expand  = options[:expand].nil?   ? true : options[:expand]
      fill    = options[:fill].nil?     ? true : options[:fill]
      padding = options[:padding].nil?  ? 0    : options[:padding]

      filterd_options = {
        expaned: expand,
        fill: fill,
        padding: padding
      }.freeze

      case options.dig(:position)
      when :start
        @box.pack_start(widget, filterd_options)
      when :end
        @box.pack_end(widget, filterd_options)
      when nil
        @box.pack_start(widget, filterd_options)
      end
    end

  end
end
