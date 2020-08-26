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

    btn1_options ={ title: "Click Here", layout: { box: box, position: :end } }
    MittensUi::Button(btn1_options) do
      MittensUi::Alert(window, "Hello #{text_box.text}!")
    end
  end
end