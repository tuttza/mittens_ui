# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A menu bar widget that renders a GTK4 popover menu bar with dropdown menus.
  # Menu items are defined as a nested hash and automatically become
  # callable methods on the FileMenu instance.
  # Wraps {https://docs.gtk.org/gtk4/class.PopoverMenuBar.html Gtk::PopoverMenuBar}
  # backed by {https://docs.gtk.org/gio/class.Menu.html Gio::Menu}.
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
      @raw_actions    = {}
      @handlers       = {}
      @action_group   = Gio::SimpleActionGroup.new

      @gio_menu = build_gio_menu
      @menu_bar = Gtk::PopoverMenuBar.new(@gio_menu)

      create_menu_methods

      super(@menu_bar, options)
    end

    private

    # Builds the Gio::Menu model from the menu items hash.
    #
    # @return [Gio::Menu] the complete menu model
    def build_gio_menu
      menu_model = Gio::Menu.new

      @menu_items.each do |root_label, menu_item_data|
        submenu = Gio::Menu.new
        next unless menu_item_data.is_a?(Hash)

        menu_item_data.each do |key, items|
          next unless key.to_sym == :sub_menus

          section = Gio::Menu.new

          items.each do |item|
            case item
            when :separator
              # append current section and start a new one
              submenu.append_section(nil, section)
              section = Gio::Menu.new
            when String
              action_name = item.downcase.gsub(/ /, '_')
              section.append(item, "filemenu.#{action_name}")
              @raw_actions[action_name] = item
            when Hash
              item.each do |sub_label, sub_items|
                nested = build_nested_menu(sub_label.to_s, sub_items)
                section.append_submenu(sub_label.to_s, nested)
              end
            end
          end

          submenu.append_section(nil, section)
        end

        menu_model.append_submenu(root_label.to_s, submenu)
      end

      menu_model
    end

    # Builds a nested Gio::Menu from a label and array of items.
    #
    # @param _label [String] the submenu label
    # @param items [Array] the submenu items
    # @return [Gio::Menu]
    def build_nested_menu(_label, items)
      menu = Gio::Menu.new
      return menu unless items.is_a?(Array)

      items.each do |item|
        if item == :separator
          # nested separators not commonly needed but supported
        elsif item.is_a?(String)
          action_name = item.downcase.gsub(/ /, '_')
          menu.append(item, "filemenu.#{action_name}")
          @raw_actions[action_name] = item
        end
      end

      menu
    end

    # Dynamically defines a method for each menu item so they can be
    # connected to blocks. Each method can only be connected once —
    # subsequent calls to the same method are no-ops.
    # Uses Gio::SimpleAction under the hood.
    #
    # @return [void]
    def create_menu_methods
      @raw_actions.each_key do |action_name|
        action = Gio::SimpleAction.new(action_name)
        @action_group.add_action(action)

        define_singleton_method(action_name.to_sym) do |&blk|
          return if @handlers[action_name]

          @handlers[action_name] = action.signal_connect('activate') do
            blk.call(self)
          end
        end
      end

      # insert action group into the widget so GTK can find it
      @menu_bar.insert_action_group('filemenu', @action_group)
    end
  end
end
