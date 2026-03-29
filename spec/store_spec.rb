require "spec_helper"
require "mittens_ui/store"
require "tmpdir"
require "fileutils"

RSpec.describe MittensUi::Store do
  let(:app_name) { "test_app" }
  let(:tmp_dir)  { Dir.mktmpdir }
  let(:store)    { described_class.new(app_name) }

  before do
    allow_any_instance_of(described_class).to receive(:data_dir).and_return(tmp_dir)
  end

  after do
    FileUtils.rm_rf(tmp_dir)
  end

  describe "#set and #get" do
    it "stores and retrieves a string value" do
      store.set(:name, "John")
      expect(store.get(:name)).to eq("John")
    end

    it "stores and retrieves an integer value" do
      store.set(:age, 42)
      expect(store.get(:age)).to eq(42)
    end

    it "stores and retrieves a boolean value" do
      store.set(:active, true)
      expect(store.get(:active)).to eq(true)
    end

    it "stores and retrieves an array value" do
      store.set(:tags, ["a", "b", "c"])
      expect(store.get(:tags)).to eq(["a", "b", "c"])
    end

    it "stores and retrieves a hash value" do
      store.set(:config, { "theme" => "dark" })
      expect(store.get(:config)).to eq({ "theme" => "dark" })
    end

    it "accepts string keys" do
      store.set("name", "Jane")
      expect(store.get("name")).to eq("Jane")
    end

    it "treats symbol and string keys as the same" do
      store.set(:name, "Jane")
      expect(store.get("name")).to eq("Jane")
    end

    it "returns nil for a missing key by default" do
      expect(store.get(:missing)).to be_nil
    end

    it "returns the default value for a missing key" do
      expect(store.get(:missing, "default")).to eq("default")
    end

    it "overwrites an existing value" do
      store.set(:name, "John")
      store.set(:name, "Jane")
      expect(store.get(:name)).to eq("Jane")
    end
  end

  describe "#delete" do
    it "removes a key" do
      store.set(:name, "John")
      store.delete(:name)
      expect(store.get(:name)).to be_nil
    end

    it "returns the deleted value" do
      store.set(:name, "John")
      expect(store.delete(:name)).to eq("John")
    end

    it "returns nil when deleting a nonexistent key" do
      expect(store.delete(:missing)).to be_nil
    end
  end

  describe "#all" do
    it "returns all stored key-value pairs" do
      store.set(:name, "John")
      store.set(:age, 42)
      expect(store.all).to eq({ name: "John", age: 42 })
    end

    it "returns an empty hash when nothing is stored" do
      expect(store.all).to eq({})
    end

    it "returns keys as symbols" do
      store.set("name", "John")
      expect(store.all.keys).to all(be_a(Symbol))
    end
  end

  describe "#clear" do
    it "removes all stored data" do
      store.set(:name, "John")
      store.set(:age, 42)
      store.clear
      expect(store.all).to eq({})
    end
  end

  describe "#include?" do
    it "returns true for an existing key" do
      store.set(:name, "John")
      expect(store.include?(:name)).to be true
    end

    it "returns false for a missing key" do
      expect(store.include?(:missing)).to be false
    end
  end

  describe "persistence" do
    it "persists data across instances" do
      store.set(:name, "John")
      new_store = described_class.new(app_name)
      expect(new_store.get(:name)).to eq("John")
    end

    it "writes data to a JSON file" do
      store.set(:name, "John")
      path = File.join(tmp_dir, "#{app_name}.json")
      data = JSON.parse(File.read(path))
      expect(data["name"]).to eq("John")
    end

    it "handles a corrupted JSON file gracefully" do
      path = File.join(tmp_dir, "#{app_name}.json")
      File.write(path, "not valid json {{{{")
      expect { described_class.new(app_name) }.not_to raise_error
      expect(store.all).to eq({})
    end

    it "handles a missing file gracefully" do
      path = File.join(tmp_dir, "#{app_name}.json")
      FileUtils.rm_f(path)
      expect { described_class.new(app_name) }.not_to raise_error
      expect(store.all).to eq({})
    end
  end
end