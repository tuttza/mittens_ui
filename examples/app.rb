require '../lib/mittens_ui'

app_options = {
  name: "say_hello",
  title: "Say Hello!",
  height: 450,
  width: 350,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do
  MittensUi::Label("Enter Name:", top: 30)

  text_box = MittensUi::Textbox(can_edit: true)

  listbox_options = {
    top: 10, 
    items: ["item_1", "item_2", "item_3"]
  }.freeze

  listbox = MittensUi::ListBox(listbox_options)

  btn = MittensUi::Button(title: "Click Here")
  btn.click {|_b| MittensUi::Alert("Hello #{text_box.text} AND! #{listbox.selected_value} was selected.") }

  s = MittensUi::Slider({ start_value: 1, stop_value: 100, initial_value: 30 })
  s.slide { |s| puts s.value }
end