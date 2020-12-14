require '../lib/mittens_ui'

app_options = {
  name: "say_hello",
  title: "Say Hello!",
  height: 450,
  width: 350,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do |window, layout|
  label_opts = { top: 30 }
  MittensUi::Label("Enter Name:", layout, label_opts)

  textbox_options = { can_edit: true }
  text_box = MittensUi::Textbox(layout, textbox_options)

  listbox_options = {
    top: 10,
    items: ["item_1", "item_2", "item_3"]
  }.freeze
  listbox = MittensUi::ListBox(layout, listbox_options)

  btn1_options = { title: "Click Here" }
  MittensUi::Button(layout, btn1_options) do
    MittensUi::Alert(window, "Hello #{text_box.text}!")
  end

  slider_opts = { start_value: 1, stop_value: 100, initial_value: 30 }
  MittensUi::Slider(layout, slider_opts) do |s|
    puts "value changed: #{s.value}"
  end
end