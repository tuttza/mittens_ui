require '../lib/mittens_ui'

app_options = {
  name: "notify_example",
  title: "Notify This",
  height: 615,
  width: 570,
  can_resize: true
}.freeze


MittensUi::Application.Window(app_options) do  
  btn = MittensUi::Button.new(title: "Notify Me")
  btn.render

  btn.click do 
    MittensUi::Notify.new("Updated!").render
  end
end
