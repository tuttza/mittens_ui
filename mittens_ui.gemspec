require_relative 'lib/mittens_ui/version'

Gem::Specification.new do |spec|
  spec.name          = "mittens_ui"
  spec.version       = MittensUi::VERSION
  spec.authors       = ["Zach Tuttle"]
  spec.email         = ["tuttle_zach@icloud.com"]
  spec.licenses      = ['MIT']
  spec.summary       = "A tiny GUI toolkit written on top of GTK"
  spec.description   = "GUI Toolkit!"
  spec.homepage      = "https://github.com/tuttza/mittens_ui"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tuttza/mittens_ui"
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
 # spec.bindir        = "exe"
  #spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  #spec.extensions    = ["ext/mittens_ui/extconf.rb"]
  spec.add_runtime_dependency("gtk3")
end
