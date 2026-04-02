require_relative "./core"

module MittensUi
  # A menu bar widget that renders a GTK menu bar with dropdown menus.
  # Menu items are defined as a nested hash and automatically become
  # callable methods on the FileMenu instance.
  #
  # @example Basic usage
  #   menus = {
  #     "File": { sub_menus: ["New", "Open", :separator, "Exit"] },
  #     "Edit": { sub_menus: ["Copy", "Paste"] }
  #   }.freeze
  #   fm = MittensUi::FileMenu.new(menus)
  #   fm.exit  { MittensUi::Application.exit }
  #   fm.new   { puts "New file" }
  #
  # @example Nested submenus
  #   menus = {
  #     "File": {
  #       sub_menus: [
  #         { "Recent": ["file1.rb", "file2.rb"] },
  #         :separator,
  #         "Exit"
  #       ]
  #     }
  #   }.freeze
  class FileMenu < Core

    # Creates a new FileMenu widget.
    #
    # @param menu_items [Hash] nested hash defining the menu structure.
    #   Top level keys are menu names. Each value is a hash with a
    #   +:sub_menus+ key containing an array of items. Items can be:
    #   - +String+ — a clickable menu item
    #   - +:separator+ — a horizontal divider line
    #   - +Hash+ — a nested submenu
    # @param options [Hash] configuration options
    # @option options [Symbol] :width (:full) column width in the layout grid
    # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
    def initialize(menu_items, options = {})
      @menu_items     = menu_items
      @menu_bar       = Gtk::MenuBar.new
      @raw_menu_items = {}
      @handlers       = {}

      associate_menu_items
      create_menu_methods

      super(@menu_bar, options)
    end

    private

    # Dynamically defines a method for each menu item so they can be
    # connected to blocks. Each method can only be connected once —
    # subsequent calls to the same method are no-ops.
    #
    # @return [void]
    def create_menu_methods
      @raw_menu_items.each do |menu_label, menu_item|
        method_name = menu_label.downcase.gsub(/ /, "_").to_sym
        define_singleton_method(method_name) do |&blk|
          return if @handlers[method_name]
          @handlers[method_name] = menu_item.signal_connect("activate") do
            blk.call(self)
          end
        end
      end
    end

    # Builds the menu bar structure from the menu items hash.
    #
    # @return [void]
    def associate_menu_items
      @menu_items.each do |root_menu_label, menu_item_data|
        root_menu      = Gtk::Menu.new
        root_menu_item = Gtk::MenuItem.new(label: root_menu_label.to_s)
        root_menu_item.set_submenu(root_menu)

        next unless menu_item_data.is_a?(Hash)

        menu_item_data.each do |sub_menus_key, sub_menus_item_data|
          next unless sub_menus_key.to_sym == :sub_menus

          sub_menus_item_data.each do |sub_menu_data|
            case sub_menu_data
            when :separator
              root_menu.append(Gtk::SeparatorMenuItem.new)
            when String
              create_root_menu(sub_menu_data, root_menu)
            when Hash
              create_sub_menu(sub_menu_data, root_menu)
            end
          end
        end

        @menu_bar.append(root_menu_item)
      end
    end

    # Creates a nested submenu from a hash.
    #
    # @param hsh [Hash] the submenu definition
    # @param root_menu [Gtk::Menu] the parent menu to attach to
    # @return [void]
    def create_sub_menu(hsh, root_menu)
      hsh.each do |sub_menu_label, sub_menu_data|
        sub_menu      = Gtk::Menu.new
        sub_menu_item = Gtk::MenuItem.new(label: sub_menu_label.to_s)
        sub_menu_item.set_submenu(sub_menu)
        root_menu.append(sub_menu_item)

        if sub_menu_data.is_a?(Array)
          sub_menu_data.each do |label|
            if label == :separator
              sub_menu.append(Gtk::SeparatorMenuItem.new)
            else
              nested_sub_item = Gtk::MenuItem.new(label: label.to_s)
              sub_menu.append(nested_sub_item)
              @raw_menu_items[label.to_s] = nested_sub_item
            end
          end
        end
      end
    end

    # Creates a single root-level menu item.
    #
    # @param label [String] the menu item label
    # @param root_menu [Gtk::Menu] the parent menu to attach to
    # @return [void]
    def create_root_menu(label, root_menu)
      menu_item = Gtk::MenuItem.new(label: label)
      root_menu.append(menu_item)
      @raw_menu_items[label] = menu_item
    end
  end
end
