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
  name: "say_hello",
  title: "Say Hello!",
  height: 450,
  width: 350,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do |window, layout|
  label_opts = { top: 30 }
  MittensUi::Label("Enter Name:", layout, label_opts)

  textbox_options = { can_edit: true }
  text_box = MittensUi::Textbox(layout, textbox_options)

  listbox_options = {
    top: 10,
    items: ["item_1", "item_2", "item_3"]
  }.freeze
  listbox = MittensUi::ListBox(layout, listbox_options)

  btn1_options = { title: "Click Here" }
  MittensUi::Button(btn1_options, layout) do
    MittensUi::Alert(window, "Hello #{text_box.text}!")
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tuttza/mittens_ui.
