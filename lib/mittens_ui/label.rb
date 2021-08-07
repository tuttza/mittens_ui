require_relative "./core"

module MittensUi
  class Label < Core
    def initialize(text, options)
      if text.nil? || text == "" || text == " "
        text = "Label"
      end

      @label = Gtk::Label.new(text)
      super(@label, options)
    end

    def render
      $vertical_box.pack_start(@label)
      return self
    end
  end
end