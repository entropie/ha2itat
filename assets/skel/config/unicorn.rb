root = "/home/ha2itats/%%identifier%%/current"
working_directory root
pid "/home/ha2itats/ha2-%%identifier%%.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/home/ha2itats/%%identifier%%.sock"
worker_processes 1
timeout 30

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end
