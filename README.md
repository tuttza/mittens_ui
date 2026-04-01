# MittensUi

A lightweight Ruby GUI toolkit built on top of GTK3, inspired by Ruby Shoes. MittensUi wraps the complexity of GTK so you can build desktop apps with plain Ruby objects and a simple, natural API — no DSLs, no magic, just Ruby.

![MittensUi Preview](https://github.com/tuttza/mittens_ui/blob/51e84d7c50282e3f2c856aa9e65fe3ed28b117ff/lib/mittens_ui/assets/mittens_ui_preview.gif)

## Requirements

MittensUi requires GTK3 native libraries to be installed on your system.

**Ubuntu / Debian**
```bash
sudo apt install build-essential libgtk-3-dev libcairo2-dev
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

Two `:half` widgets in a row sit side by side automatically. A `:full` widget always gets its own row.

### Horizontal Rows

Use `HBox` to place widgets side by side.
```ruby
MittensUi::HBox.new(spacing: 8) do
  MittensUi::Label.new("Name:")
  MittensUi::Textbox.new(can_edit: true)
  MittensUi::Button.new(title: "Save")
end
```

### Persistent Store

MittensUi includes a built-in key-value store backed by JSON, saved to `~/.local/share/mittens_ui/<app_name>.json`.
```ruby
MittensUi::Application.store.set(:theme, "dark")
MittensUi::Application.store.get(:theme)       # => "dark"
MittensUi::Application.store.get(:missing, 42) # => 42 (default)
MittensUi::Application.store.delete(:theme)
MittensUi::Application.store.all               # => { theme: "dark" }
MittensUi::Application.store.clear
```

## Widget Reference

### Label
```ruby
MittensUi::Label.new("Hello World", top: 10)
```

### Button
```ruby
btn = MittensUi::Button.new(title: "Click Me")
btn.click { puts "clicked!" }

# with loading state
btn.click do
  btn.loading do
    sleep 2  # background work
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

# multiline
tb = MittensUi::Textbox.new(multiline: true, height: 120)

# with autocomplete
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
```ruby
rb = MittensUi::RadioButton.new(
  options: ["Small", "Medium", "Large"],
  default: "Medium",
  layout:  :horizontal
)
puts rb.selected  # => "Medium"
rb.on_change { |value| puts "Selected: #{value}" }
rb.select("Large")
```

### Listbox
```ruby
# basic
lb = MittensUi::Listbox.new(items: ["Ruby", "Python", "Elixir"])
puts lb.selected_value

# with search
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
sw.on { puts "switched! status: #{sw.status}" }
puts sw.status  # => :on or :off
```

### Image
```ruby
img = MittensUi::Image.new("./assets/logo.png", width: 200, height: 200)
img.click { puts "image clicked!" }
```

### TableView
```ruby
table = MittensUi::TableView.new(
  headers: ["Name", "Email"],
  data: [
    ["John", "john@example.com"],
    ["Jane", "jane@example.com"]
  ],
  editable: true          # make all cells editable
  # editable_columns: [0] # or just specific columns
)

table.add(["Bob", "bob@example.com"])
table.add(["First", "first@example.com"], :prepend)
table.remove_selected
puts table.row_count
puts table.selected_row.inspect

table.row_clicked { |row| puts row.inspect }
table.cell_edited { |row, col, value| puts "#{row},#{col} => #{value}" }
```

### Alert
```ruby
MittensUi::Alert.new("Something happened!", title: "Notice")
```

### Notify
```ruby
MittensUi::Notify.new("Contact saved.", type: :info)  # :info, :error, :question
```

### Loader
```ruby
loader = MittensUi::Loader.new
loader.start { sleep 3 }
```

### HeaderBar
```ruby
btn = MittensUi::Button.new(title: "New", defer_render: true)
MittensUi::HeaderBar.new([btn], title: "My App", position: :left)
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
MittensUi::Separator.new                                   # horizontal (default)
MittensUi::Separator.new(:horizontal, top: 10, bottom: 10) # with margin
```

### HBox
```ruby
# block style — no defer_render needed
MittensUi::HBox.new(spacing: 8) do
  MittensUi::Button.new(title: "OK")
  MittensUi::Button.new(title: "Cancel")
end

# array style
MittensUi::HBox.new([
  MittensUi::Button.new(title: "OK",     defer_render: true),
  MittensUi::Button.new(title: "Cancel", defer_render: true)
])
```

## Full App Example

These can be inside the `examples/` directory.

```ruby
require 'mittens_ui'

MittensUi::Application.Window(name: "contacts", title: "Contacts", width: 570, height: 615) do
  file_menus = { "File": { sub_menus: ["Exit"] } }.freeze
  fm = MittensUi::FileMenu.new(file_menus)

  add_btn    = MittensUi::Button.new(title: "Add",    icon: :add_green,  defer_render: true)
  remove_btn = MittensUi::Button.new(title: "Remove", icon: :remove_red, defer_render: true)
  MittensUi::HeaderBar.new([add_btn, remove_btn], title: "Contacts", position: :left)

  table = MittensUi::TableView.new(
    headers: ["Name", "Address", "Phone #"],
    data: [
      ["John Appleseed", "123 abc st.", "111-555-3333"],
      ["Jane Doe",       "122 abc st.", "111-555-4444"],
    ]
  )

  MittensUi::Label.new("Add Contact", top: 20)
  MittensUi::HBox.new(spacing: 6) do
    name_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Name...")
    addr_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Address...")
    phne_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Phone #...")

    add_btn.click do
      table.add([name_tb.text, addr_tb.text, phne_tb.text])
      [name_tb, addr_tb, phne_tb].each(&:clear)
    end
  end

  table.row_clicked do |data|
    MittensUi::Alert.new("Name: #{data[0]}\nAddress: #{data[1]}")
  end

  remove_btn.click do
    removed = table.remove_selected
    MittensUi::Notify.new("#{removed[0]} removed.", type: :info) if removed.any?
  end

  fm.exit { MittensUi::Application.exit }
end
```

## Development

Clone the repo and install dependencies:
```bash
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
