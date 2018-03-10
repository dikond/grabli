require_relative "lib/grabli/version"

Gem::Specification.new do |spec|
  spec.name          = "grabli"
  spec.version       = Grabli::VERSION
  spec.authors       = ["dikond"]
  spec.email         = ["di.kondratenko@gmail.com"]

  spec.summary       = "Grab permissions from your Pundit policies"
  spec.homepage      = "https://github.com/dikond/grabli"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_runtime_dependncy      "pundit", "> 0"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
