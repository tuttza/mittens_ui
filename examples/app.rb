require '../lib/mittens_ui'

app_options = {
  name: "say_hello",
  title: "Say Hello!",
  height: 250,
  width: 350,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do |window| 
  MittensUi::Box(window) do |box|
    label_opts = { layout: { box: box }, top: 30 }
    MittensUi::Label("Enter Name:", label_opts)

    textbox_options = { can_edit: true, layout: { box: box } }
    text_box = MittensUi::Textbox(textbox_options)

    listbox_options = {
      layout: { box: box},
      top: 10,
      items: ["item_1", "item_2", "item_3"]
    }.freeze
    listbox = MittensUi::ListBox(listbox_options)

    puts "listbox type: #{listbox.class}"
    puts listbox.inspect
    puts listbox.methods

    btn1_options ={ title: "Click Here", layout: { box: box, position: :end } }
    MittensUi::Button(btn1_options) do
      MittensUi::Alert(window, "Hello #{text_box.text}! | #{listbox.get_selected_value}")
    end
  end
end