require '../lib/mittens_ui'

app_options = { name: 'contacts', title: 'Contacts', height: 680, width: 600, can_resize: true }.freeze

MittensUi::Application.Window(app_options) do
  puts MittensUi::Application.store.get(:last_selected_contact)

  # --- File Menu ---
  file_menus = { 'File': { sub_menus: ['Exit'] } }.freeze
  fm = MittensUi::FileMenu.new(file_menus)
  fm.exit do |_fm|
    MittensUi::Application.exit { puts 'Exiting App!' }
  end

  # --- Header Bar ---
  add_contact_button    = MittensUi::Button.new(title: 'Add',    icon: :add_green,  defer_render: true)
  remove_contact_button = MittensUi::Button.new(title: 'Remove', icon: :remove_red, defer_render: true)

  MittensUi::HeaderBar.new(
    [add_contact_button, remove_contact_button],
    title: 'Contacts',
    position: :left
  )

  # --- Contacts Table ---
  MittensUi::Separator.new(:horizontal, top: 2, bottom: 2)

  table_view_config = {
    headers: ['Name', 'Address', 'Phone #'],
    data: [
      ['John Appleseed', '123 abc st.',   '111-555-3333'],
      ['Jane Doe',       '122 abc st.',   '111-555-4444'],
      ['Bobby Jones',    '434 bfef ave.', '442-333-1342'],
      ['Sara Akigawa',   '777 tyo ave.',  '932-333-1325']
    ],
    top: 4
  }.freeze

  contacts_table = MittensUi::TableView.new(table_view_config)

  if !contacts_table.row_selected?
    remove_contact_button.enable(false)
  else
    remove_contact_button.enable(true)
  end

  contacts_table.row_double_clicked do |data|
    msg = <<~MSG
      Contact Info:
      Name:        #{data[0]}
      Address:     #{data[1]}
      Phone #:     #{data[2]}
    MSG
    MittensUi::Application.store.set(:last_selected_contact, data[0])
    MittensUi::Alert.new(msg, title: 'Contact Info')
  end

  # --- Add Contact Form ---
  MittensUi::Separator.new(:horizontal, top: 6, bottom: 2)
  MittensUi::Label.new('New Contact', top: 4, width: :full)

  name_tb = MittensUi::Textbox.new(can_edit: true, placeholder: 'Name...')
  addr_tb = MittensUi::Textbox.new(can_edit: true, placeholder: 'Address...')
  phne_tb = MittensUi::Textbox.new(can_edit: true, placeholder: 'Phone #...')

  tb_list = [name_tb, addr_tb, phne_tb].freeze

  add_contact_button.click do |btn|
    btn.click do
      if tb_list.all? { |tb| !tb.text.empty? }
        contacts_table.add(tb_list.map(&:text))
        tb_list.each(&:clear)
        MittensUi::Notify.new('Contact saved.', type: :info)
      else
        MittensUi::Notify.new('Please fill in all fields.', type: :error)
      end
    end
  end

  remove_contact_button.click do |btn|
    btn.click do
      removed = contacts_table.remove_selected
      btn.loading do
        sleep 1
        if removed.size > 0
          MittensUi::Notify.new("#{removed[0]} was removed.", type: :info)
        else
          MittensUi::Notify.new('No contact selected.', type: :error)
        end
      end
    end
  end
end
