require_relative "./core"

module MittensUi
  class FileMenu < Core
    def initialize(menu_items, options = {})
      @menu_items = menu_items

      @menu_bar = Gtk::MenuBar.new

      @raw_menu_items = { 
        # menu_name => menu_item(gtk)
      }

      associate_menu_items

      create_menu_methods
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
      @menu_items.each do |key, value|
        root_menu  = Gtk::Menu.new

        root_menu_item = Gtk::MenuItem.new(label: key.to_s)
        root_menu_item.set_submenu(root_menu)

        if value.is_a?(Hash)
          value.each do |k, v|
            next unless k.to_sym == :sub_menus

            v.each_with_index do |el, index|
              if el.is_a?(String)
                menu_item = Gtk::MenuItem.new(label: el.to_s)
                root_menu.append(menu_item)
                @raw_menu_items[el.to_s] = menu_item
              end

              if el.is_a?(Hash)
                el.each do |j, k|
                  sub_menu = Gtk::Menu.new
                  sub_menu_item = Gtk::MenuItem.new(label: j.to_s)
                  sub_menu_item.set_submenu(sub_menu)
                  root_menu.append(sub_menu_item)

                  if k.is_a?(Array)
                    k.each do |i|
                      nested_sub_item = Gtk::MenuItem.new(label: i.to_s)
                      sub_menu.append(nested_sub_item)
                      @raw_menu_items[i.to_s] = nested_sub_item
                    end
                  end
                end

              end
            end
            
          end
        end

        @menu_bar.append(root_menu_item)
      end

    end
  end
end
