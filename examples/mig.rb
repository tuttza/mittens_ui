require '../lib/mittens_ui'

# this is for testing widgets migrating from gtk3 to 4.
# https://docs.gtk.org/gtk4/migrating-3to4.html

app_options = {
  name: 'mig',
  title: 'GTK3 to GTK4 Migration Test',
  height: 615,
  width: 570,
  can_resize: true,
  theme: :light
}.freeze


MittensUi::Application.Window(app_options) do
  menus = {
    "File": { sub_menus: ['New', 'Open', :separator, 'Exit'] },
    'Edit': { sub_menus: ['Copy', 'Paste', :separator, 'Preferences'] }
  }.freeze

  fm = MittensUi::FileMenu.new(menus)
  fm.new         { puts 'New file' }
  fm.open        { puts 'Open file' }
  fm.exit        { MittensUi::Application.exit }
  fm.preferences { puts 'Preferences' }

  MittensUi::Notify.new('Hello, World!', type: :info)
  MittensUi::Notify.new('Whoa. whoa, whoa, dude', type: :error)
  MittensUi::Notify.new('did you see?', type: :question, duration: 12_000)

  img = MittensUi::Image.new('./assets/gnome_logo.png', width: 360, height: 350)
  img.click do
    puts 'image clicked!'
    puts img.inspect
  end

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  theme_btn = MittensUi::Button.new(title: 'Toggle Theme')
  theme_btn.click { MittensUi::Application.toggle_theme }

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  MittensUi::Button.new(title: 'File Picker').click do |b|
    MittensUi::FilePicker.new do |path|
      MittensUi::Alert.new("File selected: #{path}")
    end
  end

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  MittensUi::HBox.new(spacing: 20) do
    knob = MittensUi::Knob.new(min: 0, max: 100, value: 50, label: "Volume")
    knob.on_change { |v| puts "Volume: #{v}" }
    MittensUi::Knob.new(min: 0, max: 127, value: 64, label: "Cutoff",    color: [0.2, 0.6, 1.0])
    MittensUi::Knob.new(min: 0, max: 127, value: 32, label: "Resonance", color: [1.0, 0.4, 0.2])
    MittensUi::Knob.new(min: 0, max: 127, value: 80, label: "Attack",    color: [0.8, 0.8, 0.2])
    MittensUi::Knob.new(min: 0, max: 127, value: 60, label: "Release",   color: [0.6, 0.2, 1.0])
  end

  cb = MittensUi::Checkbox.new(label: "Accept terms")
  cb.value = "accepted"
  cb.toggle { puts "value: #{cb.value}" }

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  s = MittensUi::Slider.new({ start_value: 1, stop_value: 100, initial_value: 30 })
  s.slide { |value| puts "slider value: #{value}" }

  switch = MittensUi::Switch.new(left: 220)
  switch.on do
    if s.hidden?
      s.show
    else
      s.hide
    end
  end

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  MittensUi::Button.new(title: 'Select a Color').click do |_b|
    MittensUi::ColorPicker.new do |color|
      puts color.hex
      puts color.rgba
    end
  end

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  MittensUi::Label.new('A web link:', expand: true, margin: 8)
  MittensUi::WebLink.new('Open Google', 'https://google.com')

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  tb = MittensUi::Textbox.new(multiline: false, width: :full)
  tb.enable_text_completion(['Apple', 'Banana', 'Cherry'])

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)

  MittensUi::HBox.new(spacing: 10) do
    MittensUi::Label.new('Left')
    MittensUi::HBox.new(spacing: 4) do
      MittensUi::Button.new(title: 'A')
      MittensUi::Button.new(title: 'B')
    end
  end

  MittensUi::Separator.new(:horizontal, top: 10, bottom: 100)
  MittensUi::RadioButton.new({ options: %w[Red Green Blue], layout: :horizontal, bottom: 50 })

end
