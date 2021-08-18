require '../lib/mittens_ui'

app_options = {
  name: "file_menu_example",
  title: "File Menu",
  height: 615,
  width: 570,
  can_resize: true
}.freeze


MittensUi::Application.Window(app_options) do
  menu_items = {
    "File": {
      sub_menus: ["Hello", "One", "Quit"]
    },

    "Edit": {
      sub_menus: ["World", "Two", "options with space"]
    },

 "Settings": {
      sub_menus: [
        { "App Update" => ["Upgrade", "Downgrade"] }
      ]
    }

  }.freeze

  file_menu = MittensUi::FileMenu.new(menu_items)
  file_menu.render

 puts file_menu.methods.sort.inspect

  file_menu.hello do |_fm|
    MittensUi::Alert.new("HELLO!").render
  end

  file_menu.one do |_fm|
    puts "You clicked one!"
  end

  file_menu.world do |_fm|
    MittensUi::Alert.new("WORLD!").render
  end

  file_menu.quit do |_fm|
    MittensUi::Application.exit do 
      puts "quitting!"
    end
  end
end
