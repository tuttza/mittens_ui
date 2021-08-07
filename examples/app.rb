require '../lib/mittens_ui'

app_options = {
  name: "hello_world",
  title: "Hello World App!",
  height: 650,
  width: 550,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do

  MittensUi::HeaderBar([
    MittensUi::Button(title: "headerbar button"),
    MittensUi::CheckBox(label: "Checkbox")
  ], title: "Demo App", position: :left) {}

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

  img_opts = {
    tooltip_text: "The Gnome LOGO!",
    width: 200,
    height: 200,
    left: 20
  }.freeze

  img = MittensUi::Image("./assets/gnome_logo.png", img_opts)

  img2 = MittensUi::Image("./assets/mittens_ui_preview.gif", img_opts)

  switch = MittensUi::Switch(left: 220 )

  img.click do
    unless switch.hidden?
      switch.show
    else
      switch.hide
    end
  end

  switch.on do
    unless img.hidden?
      img.show
    else
      img.hide
    end 
  end

  cb = MittensUi::CheckBox(label: "Enable")
  cb.value = "Some Value"
  cb.toggle { puts "checkbox was toggled! associated value: #{cb.value}" }

  link = MittensUi::WebLink("YouTube", "https://www.youtube.com", left: 200)

  MittensUi::Label("Contact Info (use delimiter: ',')", top: 30)
  contact_tb = MittensUi::Textbox(can_edit: true)

  table_view_options = {
    headers: ["Name", "Address", "Phone #"],
    data: [ 
      [ "John Appleseed", "123 abc st.", "111-555-3333"],
      [ "Jane Doe", "122 abc st.", "111-555-4444" ],
      [ "Bobby Jones", "434 bfef ave.", "442-333-1342"],
     ],
  }
  
  table = MittensUi::TableView(table_view_options)
  table.add(["Sara Akigawa", "777 tyo ave.", "932-333-1325"], :prepend)

  add_ct = MittensUi::Button(title: "Add Contact")
  add_ct.click {|_b|  table.add(contact_tb.text.split(",")); contact_tb.clear; puts "Row Count: #{table.row_count}" }

  table.row_clicked { |row| puts row.inspect }

  remove_ct = MittensUi::Button(title: "Remove Contact")
  remove_ct.click { |btn| table.remove_selected }

  MittensUi::Shutdown() do 
    puts "quitting...."
  end

  open_file_picker = MittensUi::Button(title: "Choose File")

  open_file_picker.click do
    picked_file_path = MittensUi::FilePicker()
    puts picked_file_path.inspect
    open_file_picker.remove
  end

  start_loader = MittensUi::Button(title: "Start Loader")

  loader = MittensUi::Loader()

  start_loader.click do
    loader.start {
      puts "Doing some work..."
      num = 0
      100.times do 
        num += 1
        puts num
        sleep 0.2
      end

      start_loader.remove
    }
  end

end

