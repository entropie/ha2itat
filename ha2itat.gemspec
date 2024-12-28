Gem::Specification.new do |s|
  s.name = "ha2itat"
  s.version = "0.0.0"
  s.platform = Gem::Platform::RUBY
  s.summary = summary="Ha2itat is a repository handler for multiple hanami2 applications."
  s.license = "MIT"

  s.description = <<~EOF
    #{summary}
  EOF

  # Fixme:
  s.files = Dir['{bin/*,lib/**/*,slices/**/*,plugins/**/*,templates/**/*}'] +
    %w(LICENSE ha2itat.gemspec Rakefile.rb)

  s.bindir = 'bin'
  #s.executables << 'rackup'
  s.require_path = 'lib'


  s.author = 'Michael Trommer'
  s.email = 'mictro@gmail.com'

  s.homepage = 'https://github.com/entropie/ha2itat'

  s.required_ruby_version = '>= 3.0.0'

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/entropie/ha2itat//issues",
    "source_code_uri"   => "https://github.com/entropie/ha2itat"
  }

  hanami_version = "2.2"

  s.add_dependency "hanami",              "~> %s" % hanami_version
  s.add_dependency "hanami-router",       "~> %s" % hanami_version
  s.add_dependency "hanami-controller",   "~> %s" % hanami_version
  s.add_dependency "hanami-validations",  "~> %s" % hanami_version
  s.add_dependency "hanami-view",         "~> %s" % hanami_version
  s.add_dependency "hanami-webconsole",   "~> %s" % hanami_version

  s.add_dependency "rufus-scheduler"

  s.add_dependency "rdoc"

  s.add_dependency "dry-types",           "~> 1.0", ">= 1.6.1"

  s.add_dependency "redcarpet"
  s.add_dependency "haml"
  s.add_dependency "warden"
  s.add_dependency 'jwt'
  s.add_dependency 'bcrypt'

  s.add_dependency 'nokogiri'
  s.add_dependency 'r18n-core'

  s.add_dependency 'builder',  '~> 3.2', '>= 3.2.2'

  s.add_dependency 'capistrano', '~> 3.17'
  s.add_dependency 'capistrano-bundler' #, '~> 2.0.1'
  s.add_dependency 'capistrano-rvm'     #, '~> 0.1.2'
  s.add_dependency 'capistrano-git'     #, '~> 0.1.2'
  s.add_dependency 'sass'
  s.add_dependency 'unicorn'
  s.add_dependency 'commonmarker'
  s.add_dependency 'pony'

  s.add_development_dependency "dotenv"

  # # s.add_development_dependency 'bundler'
  # s.add_development_dependency 'minitest', '~> 5.14.4'
  # s.add_development_dependency 'rack-mini-profiler', '~> 2.3.3'
  # s.add_development_dependency 'flamegraph', '~> 0.9.5'
  # s.add_development_dependency 'fast_stack', '~> 0.2.0'

  # s.add_dependency 'bundler'
  # s.add_dependency 'rake', '~> 13.0.6'
  # s.add_dependency 'hanami', '~> 1.3.2'
  # s.add_dependency 'hanami-model', '~> 1.3.2'
  # s.add_dependency 'rack-cache', '~> 1.13.0'
  # s.add_dependency 'subcommand', '~> 1.0.7'
  # s.add_dependency 'sqlite3', '~> 1.4.2'
  # s.add_dependency 'memcached', '~> 1.8.0'
  # s.add_dependency 'puma', '>= 5.5.2', '< 5.7.0'
  # s.add_dependency 'rack', '~> 2.2.3'
  # s.add_dependency 'nokogiri', '~> 1.12.5'
  # s.add_dependency 'haml', '~> 5.2.2'
  # s.add_dependency 'sassc', '~> 2.4.0'
  # s.add_dependency 'jwt', '~> 2.3.0'
  # s.add_dependency 'warden', '~> 1.2.9'
  # s.add_dependency 'bcrypt', '~> 3.1.16'
  # s.add_dependency 'sequel', '~> 4.49.0'
  # s.add_dependency 'redcarpet', '~> 3.5.1'
  # s.add_dependency 'rake-compiler', '~> 1.1.1'
  # s.add_dependency 'unicorn', '~> 6.0.0'
  # s.add_dependency 'dimensions', '~> 1.3.0'
  # s.add_dependency 'pony', '~> 1.13.1'
  # s.add_dependency 'builder', '~> 3.2.4'
  # s.add_dependency 'sshkit', '~> 1.21.2'
  # s.add_dependency 'capistrano', '~> 3.16.0'
  # s.add_dependency 'capistrano-bundler', '~> 2.0.1'
  # s.add_dependency 'capistrano-rvm', '~> 0.1.2'
  # s.add_dependency 'multi_json', '~> 1.15.0'
  # s.add_dependency 'roar', '~> 1.1.0'
  # s.add_dependency 'uglifier', '~> 4.2.0'
  # # s.add_dependency 'webp-ffi', '~> 0.3.1'
  # s.add_dependency 'dotenv', '~> 2.7.6'
  # s.add_dependency 'flickraw', '~> 0.9.10'
end
