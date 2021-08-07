require_relative "./core"

module MittensUi
  class Textbox < Core
    def initialize(options={}) 
      @textbox    = Gtk::Entry.new
      can_edit    = options[:can_edit].nil? ?  true : options[:can_edit]
      max_length  = options[:max_length].nil? ? 200 : options[:max_length]
      placeholder_text = options[:placeholder] || ""

      @textbox.set_editable(can_edit) unless can_edit.nil?
      @textbox.set_max_length(max_length) unless max_length.nil?
      @textbox.set_placeholder_text(placeholder_text)

      super(@textbox, options)
    end

    def clear
      @textbox.text = ""
    end

    def text
      @textbox.text
    end

    def render
      $vertical_box.pack_start(@textbox)
      return self
    end
  end
end
