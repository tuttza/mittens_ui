# MittensUi

This is a small vertical stacking GUI toolkit inspired by Ruby Shoes and built on top of the GTK Ruby library. This isn't meant to be a full wrapper 
around GTK. The goal of this project is make creating GUIs in Ruby dead simple 
without the UI framework/library getting your way.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mittens_ui'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mittens_ui

## Usage

```ruby
require "mittens_ui"

app_options = {
  name: "hello_world",
  title: "Hello World App!",
  height: 650,
  width: 550,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do
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
    left: 50
  }.freeze

  img = MittensUi::Image("./assets/gnome_logo.png", img_opts)

  switch = MittensUi::Switch(left: 120 )

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
  
  remove_ct = MittensUi::Button(title: "Remove Contact")
  remove_ct.click { |btn| table.remove_selected }
  
end


```

## Development

Simply fork and clone this repo to your machine, cd into it and run `bundle install`.

This does require GTK ruby gem which requires `gtk` native dependencies to be complied and installed on your system.

#### MacOS

Using Brew:
* `$ brew install gtk+3`
* `$ brew install cairo`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tuttza/mittens_ui.
