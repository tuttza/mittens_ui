require "json"
require "fileutils"

module MittensUi
  # A simple persistent key-value store backed by a JSON file.
  # Data is saved to ~/.local/share/mittens_ui/<app_name>.json
  # and automatically reloaded on the next instantiation.
  #
  # @example Basic usage
  #   store = MittensUi::Store.new("my_app")
  #   store.set(:theme, "dark")
  #   store.get(:theme)  # => "dark"
  #
  # @example Using a default value
  #   store.get(:missing_key, "default")  # => "default"
  #
  # @example Accessing via Application
  #   MittensUi::Application.store.set(:window_width, 570)
  #   MittensUi::Application.store.get(:window_width)  # => 570
  class Store

    # Creates a new store for the given app name.
    # If a store file already exists for this app, it will be loaded automatically.
    #
    # @param app_name [String] the name of the app, used as the JSON filename
    # @example
    #   store = MittensUi::Store.new("contacts")
    def initialize(app_name)
      @app_name = app_name
      @path = File.join(data_dir, "#{app_name}.json")
      FileUtils.mkdir_p(data_dir)
      @data = load
    end

    # Stores a value under the given key and persists it to disk.
    # Symbol and string keys are treated as equivalent.
    # Values must be JSON serializable (String, Integer, Float, Boolean, Array, Hash).
    #
    # @param key [Symbol, String] the key to store under
    # @param value [Object] the value to store
    # @return [Object] the value that was stored
    # @example
    #   store.set(:theme, "dark")
    #   store.set(:window_width, 570)
    #   store.set(:recent_files, ["a.txt", "b.txt"])
    def set(key, value)
      @data[key.to_s] = value
      persist
      value
    end

    # Retrieves a value by key.
    # Returns the default value if the key does not exist.
    # Symbol and string keys are treated as equivalent.
    #
    # @param key [Symbol, String] the key to look up
    # @param default [Object] value to return if the key is not found (default: nil)
    # @return [Object, nil] the stored value, or the default if not found
    # @example
    #   store.get(:theme)               # => "dark"
    #   store.get(:missing)             # => nil
    #   store.get(:missing, "default")  # => "default"
    def get(key, default = nil)
      @data.fetch(key.to_s, default)
    end

    # Deletes a key from the store and persists the change to disk.
    # Returns nil if the key does not exist.
    #
    # @param key [Symbol, String] the key to delete
    # @return [Object, nil] the deleted value, or nil if the key was not found
    # @example
    #   store.set(:theme, "dark")
    #   store.delete(:theme)  # => "dark"
    #   store.get(:theme)     # => nil
    def delete(key)
      value = @data.delete(key.to_s)
      persist
      value
    end

    # Returns all stored key-value pairs with symbol keys.
    #
    # @return [Hash] all key-value pairs with symbol keys
    # @example
    #   store.set(:theme, "dark")
    #   store.set(:width, 570)
    #   store.all  # => { theme: "dark", width: 570 }
    def all
      @data.transform_keys(&:to_sym)
    end

    # Removes all data from the store and persists the change to disk.
    #
    # @return [void]
    # @example
    #   store.set(:theme, "dark")
    #   store.clear
    #   store.all  # => {}
    def clear
      @data = {}
      persist
    end

    # Checks whether a key exists in the store.
    # Symbol and string keys are treated as equivalent.
    #
    # @param key [Symbol, String] the key to check
    # @return [Boolean] true if the key exists, false otherwise
    # @example
    #   store.set(:theme, "dark")
    #   store.include?(:theme)    # => true
    #   store.include?(:missing)  # => false
    def include?(key)
      @data.key?(key.to_s)
    end

    private

    # Returns the directory where store files are saved.
    # Follows the XDG base directory spec on Linux.
    #
    # @return [String] the path to the data directory
    def data_dir
      File.join(Dir.home, ".local", "share", "mittens_ui")
    end

    # Loads data from the JSON file on disk.
    # Returns an empty hash if the file does not exist or is corrupted.
    #
    # @return [Hash] the loaded data
    def load
      return {} unless File.exist?(@path)
      JSON.parse(File.read(@path))
    rescue JSON::ParserError
      {}
    end

    # Writes the current data to disk as formatted JSON.
    #
    # @return [void]
    def persist
      File.write(@path, JSON.pretty_generate(@data))
    end
  end
end