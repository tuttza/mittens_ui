require_relative "./core"

module MittensUi
  class Label < Core
    def initialize(text, options = {})
      text = "Label" if text.nil? || text.strip.empty?
      @label = Gtk::Label.new(text)
      super(@label, options)
    end
  end
end