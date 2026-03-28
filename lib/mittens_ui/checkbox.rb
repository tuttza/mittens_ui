require_relative "./core"

module MittensUi
  class Checkbox < Core
    attr_accessor :value

    def initialize(options = {})
      label = options[:label] || "Checkbox"
      @value = nil
      @checkbox = Gtk::CheckButton.new(label)
      super(@checkbox, options)
    end

    def toggle
      @checkbox.signal_connect("toggled") do
        yield
      end
    end
  end
end