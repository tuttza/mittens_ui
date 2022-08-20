# MittensUi

This is a small vertical stacking GUI toolkit inspired by Ruby Shoes and built on top of the GTK Ruby library. This isn't meant to be a full wrapper 
around GTK. The goal of this project is make creating GUIs in Ruby dead simple 
without the UI framework/library getting your way.

![alt_text](https://github.com/tuttza/mittens_ui/blob/51e84d7c50282e3f2c856aa9e65fe3ed28b117ff/lib/mittens_ui/assets/mittens_ui_preview.gif "MittensUi Preview")

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
require 'mittens_ui'

app_options = {
  name: "contacts",
  title: "Contacts",
  height: 615,
  width: 570,
  can_resize: true
}.freeze


MittensUi::Application.Window(app_options) do
  file_menus = { "File": { sub_menus: ["Exit"] } }.freeze
  
  fm = MittensUi::FileMenu.new(file_menus).render

  add_contact_button    = MittensUi::Button.new(title: "Add", icon: :add_green)
  remove_contact_button = MittensUi::Button.new(title: "Remove", icon: :remove_red)

  buttons = [ add_contact_button, remove_contact_button ]

  MittensUi::HeaderBar.new(buttons.map(&:render), title: "Contacts", position: :left).render

  table_view_options = {
    headers: ["Name", "Address", "Phone #"],
    data: [ 
      [ "John Appleseed", "123 abc st.", "111-555-3333"],
      [ "Jane Doe", "122 abc st.", "111-555-4444" ],
      [ "Bobby Jones", "434 bfef ave.", "442-333-1342"],
      [ "Sara Akigawa", "777 tyo ave.", "932-333-1325"],
     ],
     top: 20
  }
  
  contacts_table = MittensUi::TableView.new(table_view_options).render

  # FORM
  MittensUi::Label.new("Add Contact", top: 30).render

  name_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Name...")
  addr_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Address...")
  phne_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Phone #...")

  tb_list = [name_tb, addr_tb, phne_tb].map(&:render).freeze

  MittensUi::HBox.new(tb_list, spacing: 10).render

  # ACTONS
  add_contact_button.click do |_b| 
    if tb_list.map { |tb| tb.text.length > 0 }.all?
      contacts_table.add(tb_list.map {|tb| tb.text })
      tb_list.map {|tb| tb.clear }
    end
  end

  remove_contact_button.click do |btn| 
    removed = contacts_table.remove_selected 

    if removed.size > 0
      MittensUi::Notify.new("#{removed[0]} was removed.", type: :info).render
    end
  end

  contacts_table.row_clicked do |data|
    msg = <<~MSG
      Contact Info:

      Name:        #{data[0]}
      Address:     #{data[1]}
      Phone #:     #{data[2]}
    MSG

    MittensUi::Alert.new(msg).render
  end

  fm.exit do |fm|
    MittensUi::Application.exit { print "Exiting App!"}
  end

end
```

## Development

Simply fork and clone this repo to your machine, cd into it and run `bundle install`.

This does require GTK ruby gem which requires `gtk` native dependencies to be complied and installed on your system.

#### Fedora
Using dnf:
* `$ sudo dnf install ruby ruby-devel cairo cairo-devel gtk3-devel`

#### Ubuntu
* `sudo apt install build-essential git sqlite3 libsqlite3-dev lib-gtk-3 libcairo2-dev`

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/tuttza/mittens_ui.

After cloning the MittensUi repo, all new PRs should be done against the `development`branch, if approved will be merged in to the `main`branch.

So:
```bash
git checkout development 
git checkout -b dev/your_feature_idea

```
