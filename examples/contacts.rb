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

contacts_table = MittensUi::TableView.new(
  ['Name', 'Email', 'Phone'],
  [
    ['John Appleseed', 'john@example.com', '555-1234'],
    ['Jane Doe', 'jane@example.com', '555-5678'],
    ['Michael Smith', 'michael.smith@email.com', '555-1001'],
    ['Emily Johnson', 'emily.j@email.com', '555-1002'],
    ['Chris Evans', 'cevans@email.com', '555-1003'],
    ['Olivia Brown', 'olivia.b@email.com', '555-1004'],
    ['Daniel Wilson', 'dan.w@email.com', '555-1005'],
    ['Sophia Martinez', 'sophia.m@email.com', '555-1006'],
    ['James Anderson', 'j.anderson@email.com', '555-1007'],
    ['Isabella Thomas', 'isabella.t@email.com', '555-1008'],
    ['Benjamin Taylor', 'ben.taylor@email.com', '555-1009'],
    ['Mia Moore', 'mia.moore@email.com', '555-1010'],
    ['Lucas Jackson', 'lucas.j@email.com', '555-1011'],
    ['Charlotte White', 'charlotte.w@email.com', '555-1012'],
    ['Henry Harris', 'henry.h@email.com', '555-1013'],
    ['Amelia Martin', 'amelia.m@email.com', '555-1014'],
    ['Alexander Thompson', 'alex.t@email.com', '555-1015'],
    ['Evelyn Garcia', 'evelyn.g@email.com', '555-1016'],
    ['William Martinez', 'will.m@email.com', '555-1017'],
    ['Harper Robinson', 'harper.r@email.com', '555-1018'],
    ['Daniel Clark', 'dan.clark@email.com', '555-1019'],
    ['Abigail Rodriguez', 'abigail.r@email.com', '555-1020'],
    ['Matthew Lewis', 'matt.lewis@email.com', '555-1021'],
    ['Ella Lee', 'ella.lee@email.com', '555-1022'],
    ['David Walker', 'd.walker@email.com', '555-1023'],
    ['Scarlett Hall', 'scarlett.h@email.com', '555-1024'],
    ['Joseph Allen', 'j.allen@email.com', '555-1025'],
    ['Grace Young', 'grace.y@email.com', '555-1026'],
    ['Samuel King', 'sam.king@email.com', '555-1027'],
    ['Chloe Wright', 'chloe.w@email.com', '555-1028'],
    ['Andrew Scott', 'andrew.s@email.com', '555-1029'],
    ['Victoria Green', 'victoria.g@email.com', '555-1030'],
    ['Joshua Adams', 'josh.adams@email.com', '555-1031'],
    ['Lily Baker', 'lily.b@email.com', '555-1032'],
    ['Ryan Nelson', 'ryan.n@email.com', '555-1033'],
    ['Zoey Carter', 'zoey.c@email.com', '555-1034'],
    ['Nathan Mitchell', 'nathan.m@email.com', '555-1035'],
    ['Hannah Perez', 'hannah.p@email.com', '555-1036'],
    ['Aaron Roberts', 'aaron.r@email.com', '555-1037'],
    ['Sofia Turner', 'sofia.t@email.com', '555-1038'],
    ['Caleb Phillips', 'caleb.p@email.com', '555-1039'],
    ['Avery Campbell', 'avery.c@email.com', '555-1040'],
    ['Ethan Parker', 'ethan.p@email.com', '555-1041'],
    ['Madison Evans', 'madison.e@email.com', '555-1042'],
    ['Logan Edwards', 'logan.e@email.com', '555-1043'],
    ['Layla Collins', 'layla.c@email.com', '555-1044'],
    ['Noah Stewart', 'noah.s@email.com', '555-1045'],
    ['Riley Sanchez', 'riley.s@email.com', '555-1046'],
    ['Jack Morris', 'jack.m@email.com', '555-1047'],
    ['Aria Rogers', 'aria.r@email.com', '555-1048'],
    ['Sebastian Reed', 'sebastian.r@email.com', '555-1049'],
    ['Nora Cook', 'nora.c@email.com', '555-1050']
  ]
)
  contacts_table.row_double_clicked do |row|
    puts "Double clicked: #{row.inspect}"
  end
  # if !contacts_table.row_selected?
  #   remove_contact_button.enable(false)
  # else
  #   remove_contact_button.enable(true)
  # end

  contacts_table.row_double_clicked do |data|
    msg = <<~MSG
      Name      :      #{data[0]}
      Address :      #{data[1]}
      Phone # :      #{data[2]}
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
