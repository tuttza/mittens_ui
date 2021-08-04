# MittensUi

This is a small vertical stacking GUI toolkit inspired by Ruby Shoes and built on top of the GTK Ruby library. This isn't meant to be a full wrapper 
around GTK. The goal of this project is make creating GUIs in Ruby dead simple 
without the UI framework/library getting your way.


![alt text](https://github.com/tuttza/mittens_ui/blob/d1c3f229d8d721add3cbf06dcfb88fa62a96f2a9/lib/mittens_ui/assets/mittens_ui_preview.gif "Mittens::Ui Preview")


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
  
  contacts_table = MittensUi::TableView(table_view_options)

 
  # FORM
  MittensUi::Label("Add Contact", top: 30)

  switch = MittensUi::Switch(left: 254)

  name_tb = MittensUi::Textbox(can_edit: true, placeholder: "Name...")
  addr_tb = MittensUi::Textbox(can_edit: true, placeholder: "Address...")
  phne_tb = MittensUi::Textbox(can_edit: true, placeholder: "Phone #...")

  tb_list = [name_tb, addr_tb, phne_tb].freeze

  add_contact_button    = nil
  remove_contact_button = nil

  buttons = [MittensUi::Button(title: "+ Add"), MittensUi::Button(title: "- Remove")]

  MittensUi::HBox(buttons, left: 190) do |widgets|
    add_contact_button, remove_contact_button = widgets
  end

  switch.activate do 
    if switch.status == :on
      tb_list.each(&:hide)
      buttons.each(&:hide)
    end 

    if switch.status == :off
      tb_list.each(&:show)
      buttons.each(&:show)
    end
  end

  # ACTONS
  add_contact_button.click do |_b| 
    if tb_list.map { |tb| tb.text.length > 0 }.all?
      contacts_table.add(tb_list.map {|tb| tb.text })
      tb_list.map {|tb| tb.clear }
    end
  end

  remove_contact_button.click do |btn| 
    removed = contacts_table.remove_selected 
    MittensUi::Alert("#{removed[0]} was removed.")
  end

  contacts_table.row_clicked do |data|
    msg = <<~MSG
      Contact Info:

      Name:        #{data[0]}
      Address:     #{data[1]}
      Phone #:     #{data[2]}
    MSG

    MittensUi::Alert(msg)
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
