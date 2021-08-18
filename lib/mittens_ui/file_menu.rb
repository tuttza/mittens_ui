require_relative "./core"

module MittensUi
  class FileMenu < Core
    def initialize(menu_items, options = {})
      @menu_items = menu_items

      @menu_bar = Gtk::MenuBar.new

      # menu_name => menu_item(gtk)
      @raw_menu_items = {}

      associate_menu_items

      create_menu_methods

      super(@menu_bar, options)
    end

    def render
      $vertical_box.pack_start(@menu_bar)
      return self
    end

    private 

    def create_menu_methods
      @raw_menu_items.each do |menu_name, menu_item|
        menu_name = menu_name.downcase.gsub(/ /, "_").to_sym

        define_singleton_method(menu_name) do |&blk|
          menu_item.signal_connect("activate") do
            blk.call(self)
          end
        end
      end
    end

    def associate_menu_items      
      @menu_items.each do |root_menu_label, menu_item_data|
        root_menu  = Gtk::Menu.new

        root_menu_item = Gtk::MenuItem.new(label: root_menu_label.to_s)
        root_menu_item.set_submenu(root_menu)

        next unless menu_item_data.is_a?(Hash)

        menu_item_data.each do |sub_menus_key, sub_menus_item_data|
          next unless sub_menus_key.to_sym == :sub_menus
          sub_menus_item_data.each do |sub_menu_data|
            sub_menu_data.is_a?(String) ? create_root_menu(sub_menu_data.to_s, root_menu) : nil
            sub_menu_data.is_a?(Hash)   ? create_sub_menu(sub_menu_data, root_menu)       : nil
          end
        end

        @menu_bar.append(root_menu_item)
      end
    end

    def create_sub_menu(hsh, root_menu)
      hsh.each do |sub_menu_label, sub_menu_data|
        sub_menu = Gtk::Menu.new
        sub_menu_item = Gtk::MenuItem.new(label: sub_menu_label.to_s)
        sub_menu_item.set_submenu(sub_menu)
        root_menu.append(sub_menu_item)

        if sub_menu_data.is_a?(Array)
          sub_menu_data.each do |label|
            nested_sub_item = Gtk::MenuItem.new(label: label.to_s)
            sub_menu.append(nested_sub_item)
            @raw_menu_items[label.to_s] = nested_sub_item
          end
        end
      end
    end

    def create_root_menu(label, root_menu)
      menu_item = Gtk::MenuItem.new(label: label)
      root_menu.append(menu_item)
      @raw_menu_items[label] = menu_item
    end
  end
end
