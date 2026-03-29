require "json"
require "fileutils"

module MittensUi

  # A simple persistent key-value store backed by JSON.
  # Data is saved to path: `~/.local/share/mittens_ui/<app_id>.json`
  # which follows the XDG spec on Linux. Each app gets its own file keyed by app_id.
  # 
  # This should be used inside the MittensUi::Application block.
  #
  # @example Basic usage
  #   store = MittensUi::Store.new("org.mittens_ui.someapp")
  #   store.set(:theme, "dark")
  #   store.get(:theme)  # => "dark"
  class Store
    def initialize(app_name)
      @app_name = app_name
      @path = File.join(data_dir, "#{app_name}.json")
      FileUtils.mkdir_p(data_dir)
      @data = load
    end

    def set(key, value)
      @data[key.to_s] = value
      persist
      value
    end

    def get(key, default = nil)
      @data.fetch(key.to_s, default)
    end

    def delete(key)
      value = @data.delete(key.to_s)
      persist
      value
    end

    def all
      @data.transform_keys(&:to_sym)
    end

    def clear
      @data = {}
      persist
    end

    def include?(key)
      @data.key?(key.to_s)
    end

    private

    def data_dir
      File.join(Dir.home, ".local", "share", "mittens_ui")
    end

    def load
      return {} unless File.exist?(@path)
      JSON.parse(File.read(@path))
    rescue JSON::ParserError
      {}
    end

    def persist
      File.write(@path, JSON.pretty_generate(@data))
    end
  end
end