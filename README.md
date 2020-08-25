# MittensUi

This is a small GUI toolkit inspired by Ruby Shoes and built on top of the GTK Ruby libraries. This isn't meant to be a wrapper 
around GTK (but kind of is right now in its early stage). The goal of this project is make creating GUIs in Ruby dead simple 
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
  title: "Say Hello!",
  height: 400,
  width: 350,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do |window| 
  MittensUi::Box(window) do |box|
    label_opts = { layout: { box: box }, top: 30 }
    MittensUi::Label("Enter Name:", label_opts)

    textbox_options = { can_edit: true, layout: { box: box } }
    text_box = MittensUi::Textbox(textbox_options)

    btn1_options ={ title: "Click Here", layout: { box: box } }
    MittensUi::Button(btn1_options) do
      MittensUi::Alert(window, "Hello #{text_box.text}!")
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tuttza/mittens_ui.
