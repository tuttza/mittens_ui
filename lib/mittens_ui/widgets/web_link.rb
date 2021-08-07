require_relative "./core"

module MittensUi
  module Widgets
    class WebLink < Core
      attr_accessor :url
      
      def initialize(name, url, options={})
        @name = name || ""
        
        @url = url || nil

        @web_link = Gtk::LinkButton.new(@url, @name)
				
        super(@web_link, options)
      end

      def render
        $vertical_box.pack_start(@web_link)
        return self
      end
    end
  end
end
