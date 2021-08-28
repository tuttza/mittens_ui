require '../lib/mittens_ui'

app_options = {
  name: "window_example",
  title: "Window Example",
  height: 615,
  width: 570,
  can_resize: true
}.freeze


MittensUi::Application.Window(app_options) do
  menu_items = {
    "File": { sub_menus: ["Hello", "One"] }
  }.freeze

  window_options = {
    title: "Sub Window!",
    widgets: {
      main_file_menu: MittensUi::FileMenu.new(menu_items),
      label: MittensUi::Label.new("hello world!"),
    }
  }.freeze

  win = MittensUi::Window.new(window_options)

  win.widgets[:main_file_menu].hello do |_fm|
    MittensUi::Alert.new("HELLO!").render
  end

  button = MittensUi::Button.new(title: "Open Window...").render

  button.click do 
    win.render
  end

end
