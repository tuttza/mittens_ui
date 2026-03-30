require '../lib/mittens_ui'

app_options = {
  name: "hello_world",
  title: "Hello World App!",
  height: 650,
  width: 550,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do
  MittensUi::HeaderBar.new(
    [
      MittensUi::Button.new(title: "click it"),
      MittensUi::Checkbox.new(label: "check it")
    ], 
    title: "Demo App", 
    position: :center
  )


  MittensUi::Label.new("Enter Name:", top: 30)
  text_box = MittensUi::Textbox.new(can_edit: true)
  
  listbox_options = {
#    top: 10,
    items: ["item_1", "item_2", "item_3"],
    searchable: true,
    search_placeholder_text: "Search Items..."
  }.freeze
  listbox = MittensUi::Listbox.new(listbox_options)
  
  btn = MittensUi::Button.new(title: "Click Here")
  btn.click {|_b| MittensUi::Alert.new("Hello #{text_box.text} AND! #{listbox.selected_value} was selected.") }
  
  s = MittensUi::Slider.new({ start_value: 1, stop_value: 100, initial_value: 30 })
  s.slide { |s| puts s.value }
  
  img_opts = {
    tooltip_text: "The Gnome LOGO!",
    width: 200,
    height: 200,
    left: 20
  }.freeze
  img = MittensUi::Image.new("./assets/gnome_logo.png", img_opts)
  switch = MittensUi::Switch.new(left: 220)
  
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


  cb = MittensUi::Checkbox.new(label: "Enable")
  cb.value = "Some Value"
  cb.toggle { puts "checkbox was toggled! associated value: #{cb.value}" }
  link = MittensUi::WebLink.new("YouTube", "https://www.youtube.com", left: 200)
  

  open_file_picker = MittensUi::Button.new(title: "Choose File")
  open_file_picker.click do
    picked_file_path = MittensUi::FilePicker.new
    puts picked_file_path.inspect
    open_file_picker.remove
  end


  start_loader = MittensUi::Button.new(title: "Start Loader")
  loader = MittensUi::Loader.new
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
      MittensUi::Notify.new("THE LOADER IS DONE LOADING!", type: :info)
    }
  end
end