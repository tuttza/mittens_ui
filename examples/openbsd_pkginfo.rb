require '../lib/mittens_ui'                                                                                                     

app_options = {
  name: "OpenBSD Packages",
  title: "OpenBSD Packages",
  height: 612,
  width: 570,
  can_resize: true
}.freeze

class Pkg
  def self.installed_count
    pkg_path = "/var/db/pkg"
    pkg_cmd = `ls -la #{pkg_path} | wc -l`

    return pkg_cmd.to_i
  end
   
  def self.info(pkg_name)
    info_cmd = `pkg_info #{pkg_name}` 
    return info_cmd
  end

  def self.fetch
    pkg_path = "/var/db/pkg"

    ls_cmd = `ls -la #{pkg_path} | awk '{ print $9 }'`

    installed_pkgs = ls_cmd.split("\n")
    installed_pkgs.map! { |pkg| pkg.gsub("\n", "") }.uniq!
    installed_pkgs.map! { |pkg| pkg.split("-").zip }

    installed_pkgs.map! do |pkg| 
      pkg_data = pkg.flatten 

      case pkg_data.size
      when 3
        #puts "case 3: #{pkg_data.inspect}"
        new_el = pkg_data[0] + "-" + pkg_data[1]
        pkg_data.delete_at(0)
        pkg_data.delete_at(0)
        pkg_data.unshift(new_el)
        #puts pkg_data.inspect
      when 4
        #puts "case 4: #{pkg_data.inspect}"
        new_el = pkg_data[0] + "-" + pkg_data[1] + "-" + pkg_data[2]
        pkg_data.delete_at(0)
        pkg_data.delete_at(0)
        pkg_data.delete_at(0)
        pkg_data.unshift(new_el)
        #puts pkg_data.inspect
      end

      pkg_data
    end

    installed_pkgs.reject! { |pkg| (pkg[0] == "." || pkg[0] == "..") }
    installed_pkgs.select! { |pkg| pkg.size == 2 }
    installed_pkgs.reject! { |pkg| pkg[0][0] == "." }
    installed_pkgs.compact
    
    return installed_pkgs
  end
end

MittensUi::Application.Window(app_options) do
  menu_item = { 
    "File": { sub_menus: ["Quit"] } 
  }

  fm = MittensUi::FileMenu.new(menu_item)
  fm.render

  MittensUi::Label.new("Installed Packages: #{Pkg.installed_count}", left: 214, right: 228).render

  installed_pkgs = Pkg.fetch

  pkg_search = MittensUi::Textbox.new(placeholder: "Search Installed Packages", top: 5, left: 14, right: 40).render

  reload_button = MittensUi::Button.new(title: "Reload Data", left: 228, right: 228)

  selected_pkg = ""

  table_opts = {                                                                                                    
    headers: ["Package", "Version"],
    data: installed_pkgs,  
  }

  table = MittensUi::TableView.new(table_opts).render
  
  table.row_clicked do |row|
    #puts "selected row: #{row}"
    selected_pkg = row.first if row.first

    pkg_info = Pkg.info(selected_pkg)
    MittensUi::Alert.new(pkg_info).render
  end

  pkg_search.on_enter do                                                                                               
    query = pkg_search.text

    if query == "" || query == " "
      table.update(installed_pkgs)
    else
      table_opts[:data] = installed_pkgs.select { |pkgs| pkgs[0].downcase.include?(query) || pkgs[1].downcase.include?(query) }
      table.update(table_opts[:data])
    end
  end
                   
  reload_button.render

  reload_button.click do
    reload_button.enable(false)
    installed_pkgs = Pkg.fetch
    table.update(installed_pkgs)
    reload_button.enable(true)
  end

  fm.quit { exit(0) }

end
