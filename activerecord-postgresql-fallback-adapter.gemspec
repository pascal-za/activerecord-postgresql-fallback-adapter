# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "activerecord-postgresql-fallback-adapter"
  spec.version       = "0.0.1"
  spec.authors       = ["Pascal Houliston"]
  spec.email         = ["101pascal@gmail.com"]

  spec.summary       = %q{Default ActiveRecord PostgreSQL adapter with support for fallback hosts and high availability}
  spec.homepage      = "https://github.com/pascalh1011/activerecord-postgresql-fallback-adapter"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.15"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
 
  rails_version = ENV['RAILS_VERSION'] || '5.1'

  spec.add_runtime_dependency "activerecord", "~> #{rails_version}"
  spec.add_runtime_dependency "activesupport", "~> #{rails_version}"
  spec.add_runtime_dependency "pg", ">= 0.21.0" # PGConn deprecation
end
