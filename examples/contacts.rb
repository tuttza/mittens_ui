require '../lib/mittens_ui'

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
 
  contacts_search = MittensUi::Textbox.new(placeholder: "Search Contacts...", top: 10).render

  add_contact_button = MittensUi::Button.new(title: "Add", icon: :add_green)
  remove_contact_button = MittensUi::Button.new(title: "Remove", icon: :remove_red)
  buttons = [ add_contact_button, remove_contact_button ]

  MittensUi::HeaderBar.new(buttons.map(&:render), title: "Contacts", position: :left).render

  initial_contacts_data = [
    [ "John Appleseed", "123 abc st.", "111-555-3333"],
    [ "Jane Doe", "122 abc st.", "111-555-4444" ],
    [ "Bobby Jones", "434 bfef ave.", "442-333-1342"],
    [ "Sara Akigawa", "777 tyo ave.", "932-333-1325"],
  ]

  table_view_options = {
    headers: ["Name", "Address", "Phone #"],
    data: initial_contacts_data,
    top: 20
  }
  
  contacts_table = MittensUi::TableView.new(table_view_options).render

  # WINDOW FORM
  #
  name_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Name...", top: 20)
  addr_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Address...")
  phne_tb = MittensUi::Textbox.new(can_edit: true, placeholder: "Phone #...")
  close_win = MittensUi::Button.new(title: "Done")
  add_window_widgets = [name_tb, addr_tb, phne_tb, close_win].freeze

  add_window_options = { title: "Add Contact", widgets: add_window_widgets }
  add_window = MittensUi::Window.new(add_window_options)

  #MittensUi::Label.new("Add Contact", top: 30).render


  #MittensUi::HBox.new(tb_list, spacing: 10).render

  # ACTONS
  add_contact_button.click do |_b| 
    add_window.render
  end

  close_win.click do |_b| 
    if name_tb.text.length > 0 
      contacts_table.add([name_tb.text, addr_tb.text, phne_tb.text])
    end

    name_tb.clear  
    addr_tb.clear
    phne_tb.clear

    add_window.close
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
        * Name:        #{data[0]}
        * Address:     #{data[1]}
        * Phone #:     #{data[2]}
    MSG

    MittensUi::Alert.new(msg).render
  end

  fm.exit do |fm|
    MittensUi::Application.exit { print "Exiting App!"}
  end

  contacts_search.on_enter do
    query = contacts_search.text

    if query == "" || query == " "
      contacts_table.update(initial_contacts_data)
    else
      table_view_options[:data] = initial_contacts_data.select { |contact_array| contact_array[0].downcase.include?(query) }
      contacts_table.update(table_view_options[:data])
    end
  end

end
