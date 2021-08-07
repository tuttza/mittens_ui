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

    def enable_text_completion(data)
      completion = Gtk::EntryCompletion.new
      @textbox.completion = completion

      model = Gtk::ListStore.new(String)

      data.each do |value|
        iter = model.append
        iter[0] = value
      end

      completion.model = model
      completion.text_column = 0
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
