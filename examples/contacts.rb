require '../lib/mittens_ui'

app_options = {
  name: "contacts",
  title: "Contacts",
  height: 615,
  width: 570,
  can_resize: true
}.freeze

MittensUi::Application.Window(app_options) do
  puts MittensUi::Application.store.get(:last_selected_contact)

  file_menus = { "File": { sub_menus: ["Exit"] } }.freeze
  fm = MittensUi::FileMenu.new(file_menus)

  add_contact_button    = MittensUi::Button.new(title: "Add",    icon: :add_green,  defer_render: true)
  remove_contact_button = MittensUi::Button.new(title: "Remove", icon: :remove_red, defer_render: true)
  MittensUi::HeaderBar.new([add_contact_button, remove_contact_button], title: "Contacts", position: :left)

  table_view_config = {
    headers: ["Name", "Address", "Phone #"],
    data: [
      ["John Appleseed", "123 abc st.", "111-555-3333"],
      ["Jane Doe",       "122 abc st.", "111-555-4444"],
      ["Bobby Jones",    "434 bfef ave.", "442-333-1342"],
      ["Sara Akigawa",   "777 tyo ave.", "932-333-1325"],
    ],
    editable_columns: [0, 1, 2],
    top: 5
  }
  contacts_table = MittensUi::TableView.new(table_view_config)

  contacts_table.cell_edited do |row, col, value|
    puts "Row #{row}, col #{col} changed to: #{value}"
  end

  MittensUi::Label.new("Add Contact:", top: 22)

  name_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Name...")
  addr_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Address...")
  phne_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Phone #...")
  tb_list = [name_tb, addr_tb, phne_tb].freeze

  add_contact_button.click do |_b|
    if tb_list.all? { |tb| tb.text.length > 0 }
      MittensUi::Notify.new("Saved contact", type: :info)
      contacts_table.add(tb_list.map(&:text))
      tb_list.each(&:clear)
    end
  end

  remove_contact_button.click do |btn|
    removed = contacts_table.remove_selected
    btn.loading do
      sleep 3
      if removed.size > 0
        MittensUi::Notify.new("#{removed[0]} was removed.", type: :info)
      end
    end
  end

  contacts_table.row_clicked do |data|
    msg = <<~MSG
      Contact Info:
      Name:        #{data[0]}
      Address:     #{data[1]}
      Phone #:     #{data[2]}
    MSG

    MittensUi::Application.store.set(:last_selected_contact, data[0])

    MittensUi::Alert.new(msg, title: "Contact Entry")
  end

  MittensUi::HBox.new(spacing: 8) do
    MittensUi::Label.new("Outer left")
    MittensUi::HBox.new(spacing: 4) do          # pushes inner HBox
      MittensUi::Button.new(title: "Inner A")    # goes into inner HBox
      MittensUi::Button.new(title: "Inner B")    # goes into inner HBox
    end                                          # pops inner HBox
    MittensUi::Label.new("Outer right")         # goes back into outer HBox
  end

  fm.exit do |_fm|
    MittensUi::Application.exit { puts "Exiting App!" }
  end
end
