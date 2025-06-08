load File.join(File.dirname(File.expand_path(__FILE__)), "../vendor/gems/ha2itat/lib/ha2itat.rb")

Q = Ha2itat.quart

set :application, Q.identifier.to_s

set :ha2itat_repo, "git@github.com:entropie/ha2itat.git"

set :vendor_gems, [
      "git@github.com:entropie/ha2itat.git",
      "git@github.com:entropie/trompie.git",
      "git@github.com:entropie/ytdltt.git",
    ]

set :repo_url,     "/home/mit/Source/quarters/#{Q.identifier}.git"


set :media_path,   "/home/mit/Data/quarters/newmedia/#{fetch(:application)}"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/ha2itats/#{fetch(:application)}/"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

server "wecoso", roles: %w{web app db}

set    :branch, 'master'

set    :ha2itat, release_path

set    :nginx_config, "/etc/nginx/sites-enabled/ha2-#{fetch(:application)}.conf"

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def remote_link_exists?(full_path)
  'true' ==  capture("if test -L #{full_path}; then echo 'true'; fi").strip
end

def nix_shell(cmd)
  "nix-shell #{fetch(:release_path)}/shell.nix --run '#{cmd}'"
end

Rake::Task["bundler:install"].clear
Rake::Task["bundler:config"].clear

namespace :bundler do
  task :config do
    on fetch(:bundle_servers) do
      within release_path do
        with fetch(:bundle_env_variables) do
          configuration = fetch(:bundle_config).dup || {}
          configuration[:gemfile] = fetch(:bundle_gemfile)
          configuration[:path] = fetch(:bundle_path)
          configuration[:without] = fetch(:bundle_without)

          configuration.each do |key, value|
            unless value.nil?
              args = "bundle", "config", "--local", key, value.to_s.shellescape
              execute "nix-shell", "--run", "'#{args.join(" ")}'"
            end
          end
        end
      end
    end
  end

  task install: :config do
    on fetch(:bundle_servers) do
      within release_path do
        options = []
        if fetch(:bundle_binstubs) &&
           fetch(:bundle_binstubs_command) == :install
          options << "--binstubs #{fetch(:bundle_binstubs)}"
        end
        options << "--jobs #{fetch(:bundle_jobs)}" if fetch(:bundle_jobs)
        options << "#{fetch(:bundle_flags)}" if fetch(:bundle_flags)

        args = "'bundle install #{options.join(' ')}'"
        execute "nix-shell", "--run", *args
      end
    end
  end
end

before "bundler:install", "ha2itat:copy_nix_shell"

namespace :ha2itat do

  task :copy_nix_shell do
    on roles(:app) do
      shellnix = release_path.join("shell.nix")
      # if project has own /shell.nix dont overwrite
      unless remote_file_exists?(shellnix)
        sudo :cp, "/etc/nixos/res/ha2itat-shell.nix #{shellnix}"
      end
    end
  end

  task :restart do
    on roles(:app) do
      sudo :systemctl, "restart h2-#{fetch(:application)}"
    end
  end

  after "deploy:log_revision", "ha2itat:restart"


  task :link_files do
    on roles(:app) do
      unless remote_link_exists?(fetch(:nginx_config))
        sudo :ln, "-s #{current_path.join("config/nginx.conf")} #{fetch(:nginx_config)}"
      end

      # unless remote_link_exists?(fetch(:init_file))
      #   sudo :ln, "-s #{current_path.join("config/init.sh")} #{fetch(:init_file)} "
      # end
    end
  end

  task :link_media do
    on roles(:app) do
      ha2itat_media_path = release_path.join("media")
      unless remote_link_exists?(ha2itat_media_path)
        execute :ln, "-s #{fetch(:media_path)} #{ha2itat_media_path}"
      end
    end
  end

  before "deploy:cleanup", "ha2itat:link_media"


  task :npm_install do
    on roles(:app) do
      nsp = "cd #{fetch(:release_path)} && nix-shell --run '%s'"
      execute nsp % "bundle exec ruby vendor/gems/ha2itat/bin/generate_js.rb"
      execute nsp % "npm install --legacy-peer-deps --silent"
      execute nsp % "npm run production --silent"
    end
  end

  before "deploy:cleanup", "ha2itat:npm_install"


  task :checkout do
    on roles(:app) do
      within release_path.join("vendor/gems") do
        fetch(:vendor_gems).each do |vg|
          execute :git, "clone #{vg}"
        end
      end
    end
  end

  before "bundler:config", "ha2itat:checkout"

  task :setup do;  end
  # before "ha2itat:setup", "ha2itat:link_files"
  after "ha2itat:link_media", "ha2itat:link_files"

end
