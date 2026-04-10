# frozen_string_literal: true

require 'mittens_ui/core'

module MittensUi
  # A clickable hyperlink widget that opens a URL in the user's default browser.
  # Wraps {https://docs.gtk.org/gtk4/class.LinkButton.html Gtk::LinkButton}.
  #
  # @example Basic usage
  #   MittensUi::WebLink.new("Open Google", "https://google.com")
  #
  # @example With layout options
  #   MittensUi::WebLink.new(
  #     "Docs",
  #     "https://docs.example.com",
  #     top: 10,
  #     bottom: 10,
  #     width: :half
  #   )
  #
  # @param name [String] The visible label of the link
  # @param url [String] The URL to open when clicked
  # @param options [Hash] configuration options
  # @option options [Symbol] :width (:full) column width in the layout grid
  # @option options [Integer] :top top margin in pixels
  # @option options [Integer] :bottom bottom margin in pixels
  # @option options [Integer] :left left margin in pixels
  # @option options [Integer] :right right margin in pixels
  # @option options [Boolean] :defer_render (false) skip auto-rendering into layout
  #
  # @attr_accessor [String] url The URL associated with the link
  class WebLink < Core
    attr_accessor :url

    # Creates a new WebLink widget.
    #
    # @param name [String] The visible label of the link
    # @param url [String] The URL to open when clicked
    # @param options [Hash] configuration options
    def initialize(name, url, options = {})
      @name = name || ''
      @url  = url  || ''
      @web_link = Gtk::LinkButton.new(@url, @name)
      super(@web_link, options)
    end

    def open_url
      launcher = Gtk::UriLauncher.new(@url)
      launcher.launch
    end
  end
end
