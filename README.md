# MittensUi

A lightweight Ruby GUI toolkit built on top of GTK, inspired by Ruby Shoes. MittensUi wraps the complexity of GTK so you can build desktop apps with plain Ruby objects and a simple, natural API — no DSLs, no magic, just Ruby.

We will always try to keep up with the latest GTK updates.

## Requirements

MittensUi requires GTK native libraries to be installed on your system.

**Ubuntu / Debian**
```bash
sudo apt install build-essential libgtk-4-dev libcairo2-dev
```

**macOS**
```bash
brew install gtk+4 cairo pkg-config
```

## Installation

Add to your Gemfile:
```ruby
gem 'mittens_ui'
```

Then run:
```bash
bundle install
```

Or install directly:
```bash
gem install mittens_ui
```

## Quick Start
```ruby
require 'mittens_ui'

MittensUi::Application.Window(name: "my_app", title: "Hello World", width: 400, height: 300) do
  MittensUi::Label.new("What is your name?")
  name_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Enter name...")
  btn = MittensUi::Button.new(title: "Say Hello")
  btn.click do
    MittensUi::Alert.new("Hello, #{name_tb.text}!")
  end
end
```

## Core Concepts

### Application Window

Every MittensUi app starts with `Application.Window`. All widgets are created inside the block.
```ruby
MittensUi::Application.Window(
  name:       "my_app",   # used as process name and store identifier
  title:      "My App",   # window title bar text
  width:      400,        # window width in pixels
  height:     600,        # window height in pixels
  can_resize: true,       # whether the window is resizable
  icon:       "icon.png"  # optional path to a window icon
) do
  # widgets go here
end
```

### Layout System

MittensUi uses a 12-unit grid layout. Every widget accepts a `:width` option that controls how many columns it occupies.
```ruby
MittensUi::Label.new("Full width",    width: :full)    # 12 units
MittensUi::Label.new("Half width",    width: :half)    # 6 units
MittensUi::Label.new("Third width",   width: :third)   # 4 units
MittensUi::Label.new("Quarter width", width: :quarter) # 3 units
```

Two `:half` widgets placed back to back sit side by side automatically. A `:full` widget always gets its own row.

### Horizontal Rows

Use `HBox` to place widgets side by side in a row. The block style is recommended — no `defer_render` needed:
```ruby
MittensUi::HBox.new(spacing: 8) do
  MittensUi::Label.new("Name:")
  MittensUi::Textbox.new(can_edit: true)
  MittensUi::Button.new(title: "Save")
end
```

`HBox` supports nesting:
```ruby
MittensUi::HBox.new(spacing: 8) do
  MittensUi::Label.new("Left")
  MittensUi::HBox.new(spacing: 4) do
    MittensUi::Button.new(title: "A")
    MittensUi::Button.new(title: "B")
  end
  MittensUi::Label.new("Right")
end
```

### Persistent Store

MittensUi includes a built-in key-value store backed by JSON, saved to `~/.local/share/mittens_ui/<app_name>.json`. Data persists across app launches automatically.
```ruby
MittensUi::Application.store.set(:theme, "dark")
MittensUi::Application.store.get(:theme)        # => "dark"
MittensUi::Application.store.get(:missing, 42)  # => 42 (default)
MittensUi::Application.store.delete(:theme)
MittensUi::Application.store.all                # => { theme: "dark" }
MittensUi::Application.store.clear
```

## Widget Reference

### Knob

A rotary knob widget inspired by synthesizer hardware. Click and drag up or right to increase the value, down or left to decrease it. Scroll wheel also works.
```ruby
knob = MittensUi::Knob.new(min: 0, max: 100, value: 50, label: "Volume")
knob.on_change { |v| puts "Volume: #{v}" }

# custom color and size
knob = MittensUi::Knob.new(
  min:   0,
  max:   127,
  value: 64,
  size:  80,
  label: "Cutoff",
  color: [0.2, 0.6, 1.0]
)

# programmatic control
knob.value = 75
puts knob.value  # => 75.0

# row of synth knobs
MittensUi::HBox.new(spacing: 8) do
  MittensUi::Knob.new(min: 0, max: 127, value: 64, label: "Cutoff",    color: [0.2, 0.6, 1.0])
  MittensUi::Knob.new(min: 0, max: 127, value: 32, label: "Resonance", color: [1.0, 0.4, 0.2])
  MittensUi::Knob.new(min: 0, max: 127, value: 80, label: "Attack",    color: [0.8, 0.8, 0.2])
  MittensUi::Knob.new(min: 0, max: 127, value: 60, label: "Release",   color: [0.6, 0.2, 1.0])
end
```

### Label
```ruby
MittensUi::Label.new("Hello World", top: 10)
```

### Button
```ruby
btn = MittensUi::Button.new(title: "Click Me")
btn.click { puts "clicked!" }
```

Buttons support a loading state that disables the button and shows a spinner while background work runs:
```ruby
btn.click do
  btn.loading do
    sleep 2  # runs in background thread
    puts "done!"
  end
end
```

### Textbox
```ruby
# single line
tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Enter text...")
puts tb.text
tb.clear

# password field
tb = MittensUi::Textbox.new(password: true)

# multiline text area
tb = MittensUi::Textbox.new(multiline: true, height: 120)

# with autocomplete suggestions
tb = MittensUi::Textbox.new(can_edit: true)
tb.enable_text_completion(["Ruby", "Rails", "Rack"])
```

### Checkbox
```ruby
cb = MittensUi::Checkbox.new(label: "Enable notifications")
cb.value = "notifications"
cb.toggle { puts "toggled! value: #{cb.value}" }
```

### RadioButton

A group of mutually exclusive options. Only one can be selected at a time.
```ruby
rb = MittensUi::RadioButton.new(
  options: ["Small", "Medium", "Large"],
  default: "Medium",
  layout:  :horizontal  # or :vertical
)
puts rb.selected               # => "Medium"
rb.on_change { |v| puts v }   # fires on selection change
rb.select("Large")             # programmatic selection
```

### Listbox
```ruby
# basic dropdown
lb = MittensUi::Listbox.new(items: ["Ruby", "Python", "Elixir"])
puts lb.selected_value

# with search box
lb = MittensUi::Listbox.new(items: ["Ruby", "Python", "Elixir"], searchable: true)
lb.update_items(["Go", "Rust", "Zig"])
lb.clear_search
```

### Slider
```ruby
s = MittensUi::Slider.new(start_value: 0, stop_value: 100, initial_value: 50)
s.slide { |widget| puts widget.value }
```

### Switch
```ruby
sw = MittensUi::Switch.new
sw.on { puts "status: #{sw.status}" }
puts sw.status  # => :on or :off
```

### Image
```ruby
img = MittensUi::Image.new("./assets/logo.png", width: 200, height: 200)
img.click { puts "image clicked!" }

# GIF support
img = MittensUi::Image.new("./assets/animation.gif")
```

### TableView
```ruby
table = MittensUi::TableView.new(
  ['Name', 'Email'],
  [['John', 'john@example.com']]
)

table.add(['Jane', 'jane@example.com'])

table.row_clicked { |row| puts row.inspect }
table.row_double_clicked { |row| puts "Double: #{row.inspect}" }
```

### Alert
```ruby
MittensUi::Alert.new("Something happened!", title: "Notice")
```

### Notify
```ruby
MittensUi::Notify.new("Saved!", type: :info)      # banner notification
# types: :info, :error, :question
```

### Loader
```ruby
loader = MittensUi::Loader.new
loader.start do
  sleep 3  # runs in background thread
end
```

### HeaderBar
```ruby
btn = MittensUi::Button.new(title: "New", defer_render: true)
MittensUi::HeaderBar.new([btn], title: "My App", position: :left)
# position: :left or :right
```

### FileMenu
```ruby
menus = {
  "File": { sub_menus: ["New", "Open", "Exit"] },
  "Edit": { sub_menus: ["Copy", "Paste"] }
}.freeze

fm = MittensUi::FileMenu.new(menus)
fm.exit { MittensUi::Application.exit }
fm.new  { puts "New file" }
```

### FilePicker
```ruby
picker = MittensUi::FilePicker.new
puts picker.path  # => "/home/user/file.txt" or nil if cancelled
```

### WebLink
```ruby
MittensUi::WebLink.new("GitHub", "https://github.com")
```

### Separator
```ruby
MittensUi::Separator.new                                    # horizontal (default)
MittensUi::Separator.new(:horizontal, top: 10, bottom: 10)  # with margin
```

### HBox
```ruby
# block style
MittensUi::HBox.new(spacing: 8) do
  MittensUi::Button.new(title: "OK")
  MittensUi::Button.new(title: "Cancel")
end

# nested HBox
MittensUi::HBox.new(spacing: 8) do
  MittensUi::Label.new("Tools:")
  MittensUi::HBox.new(spacing: 4) do
    MittensUi::Button.new(title: "Cut")
    MittensUi::Button.new(title: "Copy")
    MittensUi::Button.new(title: "Paste")
  end
end

# array style — requires defer_render: true on each widget
MittensUi::HBox.new([
  MittensUi::Button.new(title: "OK",     defer_render: true),
  MittensUi::Button.new(title: "Cancel", defer_render: true)
])
```

## Development

**Setup Ruby**
# setup and install Ruby if you have not done so:
```bash
rbenv install 4.0.0
rbenv global 4.0.0`
```

**Linux**
```bash
git clone https://github.com/tuttza/mittens_ui.git
cd mittens_ui
bundle install
```

**macOS**
```bash
brew install gtk+3 cairo pkg-config rbenv

git clone https://github.com/tuttza/mittens_ui.git
cd mittens_ui
bundle install
```

Run the test suite:
```bash
bundle exec rspec
```

Generate docs:
```bash
bundle exec yard doc
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tuttza/mittens_ui.

## License

Available under the MIT License.
