require_relative "./core"

module MittensUi
  class WebLink < Core
    attr_accessor :url

    def initialize(name, url, options = {})
      @name = name || ""
      @url  = url  || ""
      @web_link = Gtk::LinkButton.new(@url, @name)
      super(@web_link, options)
    end
  end
end