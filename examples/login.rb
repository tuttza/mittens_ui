require '../lib/mittens_ui'
require "net/http"



def login
  app_options = {
    name: "example_app",
    title: "Login Example",
    height: 400,
    width: 370,
    can_resize: false
  }.freeze

  can_login = false

  MittensUi::Application.Window(app_options) do |window| 
    MittensUi::Box(window, spacing: 10) do |box|
      MittensUi::Label("email:", { layout: { box: box, top: 30, right: 300 } })

      email_textbox_options = { can_edit: true, layout: { box: box } }
      email_tb = MittensUi::Textbox(email_textbox_options)

      MittensUi::Label("password:", { layout: { box: box, top: 30, right: 290 } })
      password_textbox_options = { can_edit: true, layout: { box: box } }
      password_tb = MittensUi::Textbox(password_textbox_options)

      btn1_options = { title: "Login", layout: { box: box, bottom: 30, position: :end } }
      
      MittensUi::Button(btn1_options) do
        if email_tb.text && password_tb.text
          can_login = true
          MittensUi::HideVisible()
        end
      end
    end
  end

  return can_login
end

def welcome(window)
  MittensUi::Box(window, spacing: 10) do |box|
    MittensUi::Label("WELCOME", { layout: { box: box, top: 30 } })
  end
end

app_options = {
  name: "example_app",
  title: "Your Logged in!",
  height: 400,
  width: 370,
  can_resize: false
}.freeze

if login
  MittensUi::Application.Window(app_options) do |window| 
    welcome(window)
  end
end

