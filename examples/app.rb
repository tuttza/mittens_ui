require '../lib/mittens_ui'
require "net/http"

app_options = {
  name: "say_hello",
  title: "Say Hello!",
  height: 450,
  width: 350,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do |window| 
  MittensUi::Box(window, spacing: 10) do |box|
    label_opts = { layout: { box: box, top: 30 } }
    MittensUi::Label("Enter Name:", label_opts)

    textbox_options = { can_edit: true, layout: { box: box } }
    text_box = MittensUi::Textbox(textbox_options)

    listbox_options = {
      layout: { box: box},
      top: 10,
      items: ["item_1", "item_2", "item_3"]
    }.freeze
    listbox = MittensUi::ListBox(listbox_options)

    job = MittensUi::Job.new("sleep")
    job.run { 
      puts "sleeping for 5 secs"
      sleep(5)
      puts "done sleeping!"
    }

    job2 = MittensUi::Job.new("GET example.com")
    job.run {
      uri = URI('http://example.com/index.html')
      params = { :limit => 10, :page => 3 }
      uri.query = URI.encode_www_form(params)

      res = Net::HTTP.get_response(uri)
      puts res.body if res.is_a?(Net::HTTPSuccess)
    }

    listbox2_options = {
      layout: { box: box},
      top: 10,
      items: ["item_4", "item_5", "item_6"]
    }.freeze
    listbox2 = MittensUi::ListBox(listbox2_options)

    btn1_options = { title: "Click Here", layout: { box: box, bottom: 20, position: :end } }
    MittensUi::Button(btn1_options) do
      MittensUi::Alert(window, "Hello #{text_box.text}! | #{listbox.get_selected_value}")
    end
  end
end