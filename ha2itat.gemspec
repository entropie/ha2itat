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

  s.add_dependency 'mime-types'
  
  hanami_version = "2.2"


  s.add_dependency "hanami",              "~> %s" % hanami_version
  s.add_dependency "hanami-router",       "~> %s" % hanami_version
  s.add_dependency "hanami-controller",   "~> %s" % hanami_version
  s.add_dependency "hanami-validations",  "~> %s" % hanami_version
  s.add_dependency "hanami-view",         "~> %s" % hanami_version
  s.add_dependency "hanami-webconsole",   "~> %s" % hanami_version

  s.add_dependency "rufus-scheduler",     "~> 3.9.2"

  s.add_dependency "rdoc"

  s.add_dependency "dry-types",           "~> 1.0", ">= 1.6.1"

  s.add_dependency "redcarpet"
  s.add_dependency "haml",                "~> 6.3.0"
  s.add_dependency "warden"
  s.add_dependency 'jwt'
  s.add_dependency 'bcrypt'

  s.add_dependency 'minitest'

  s.add_dependency 'nokogiri'
  s.add_dependency 'r18n-core'

  s.add_dependency 'builder',  '~> 3.2', '>= 3.2.2'

  s.add_dependency 'net-ssh' #, '~> 1.2'
  s.add_dependency 'sshkit', '~> 1.7'

  s.add_dependency 'capistrano', '~> 3.17'
  s.add_dependency 'capistrano-bundler' #, '~> 2.0.1'
  s.add_dependency 'capistrano-git'     #, '~> 0.1.2'
  s.add_dependency 'sass'
  s.add_dependency 'unicorn'
  s.add_dependency 'commonmarker'
  s.add_dependency 'pony'

  s.add_dependency "mini_magick"
  s.add_dependency "image_processing"

  s.add_dependency 'relative_time'

  s.add_development_dependency "dotenv"

  s.add_dependency 'bundler', '~> 2.7.2'
end
