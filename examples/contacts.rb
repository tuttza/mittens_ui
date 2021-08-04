require '../lib/mittens_ui'

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
      add_contact_button.hide
      remove_contact_button.hide
    end 

    if switch.status == :off
      tb_list.each(&:show)
      add_contact_button.show
      remove_contact_button.show
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
