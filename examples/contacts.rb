require '../lib/mittens_ui'

app_options = {
  name: "contacts",
  title: "Contacts",
  height: 615,
  width: 570,
  can_resize: true
}.freeze


MittensUi::Application.Window(app_options) do
  add_contact_button    = MittensUi::Button.new(title: "Add")
  remove_contact_button = MittensUi::Button.new(title: "Remove")

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

  fp = MittensUi::FilePicker.new

  # ACTONS

  add_contact_button.click do |_b| 
    if tb_list.map { |tb| tb.text.length > 0 }.all?
      contacts_table.add(tb_list.map {|tb| tb.text })
      tb_list.map {|tb| tb.clear }
        puts "#{fp.render.path}"
    end
  end

  remove_contact_button.click do |btn| 
    removed = contacts_table.remove_selected 

    if removed.size > 0
      MittensUi::Alert.new("#{removed[0]} was removed.").render
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
end
