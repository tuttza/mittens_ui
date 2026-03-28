require_relative "./core"

module MittensUi
  class Textbox < Core
    def initialize(options = {})
      @textbox         = Gtk::Entry.new
      can_edit         = options.fetch(:can_edit, true)
      max_length       = options[:max_length]  || 200
      has_password     = options[:password]    || false
      placeholder_text = options[:placeholder] || ""
      @textbox.set_visibility(false) if has_password
      @textbox.set_editable(can_edit)
      @textbox.set_max_length(max_length)
      @textbox.set_placeholder_text(placeholder_text)
      super(@textbox, options)
    end

    def text
      @textbox.text
    end

    def clear
      @textbox.text = ""
    end

    def enable_text_completion(data)
      completion = Gtk::EntryCompletion.new
      model = Gtk::ListStore.new(String)
      data.each do |value|
        iter = model.append
        iter[0] = value
      end
      completion.model = model
      completion.text_column = 0
      @textbox.completion = completion
    end
  end
end