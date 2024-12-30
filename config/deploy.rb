load File.join(File.dirname(File.expand_path(__FILE__)), "../vendor/gems/ha2itat/lib/ha2itat.rb")

Q = Ha2itat.quart

set :application, Q.identifier.to_s

set :ha2itat_repo, "git@github.com:entropie/ha2itat.git"

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

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

server "hive", roles: %w{web app db}

set    :branch, 'master'

set    :ha2itat, release_path

set    :nginx_config, "/etc/nginx/sites-enabled/ha2-#{fetch(:application)}.conf"
set    :init_file,    "/etc/init.d/h2-unicorn-#{fetch(:application)}"

set    :rvm_ruby_version, '3.2.2'

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def remote_link_exists?(full_path)
  'true' ==  capture("if test -L #{full_path}; then echo 'true'; fi").strip
end

namespace :ha2itat do

  task :restart do
    on roles(:app) do
      execute fetch(:init_file), "stop"
      execute fetch(:init_file), "start"
    end
  end

  after "deploy:log_revision", "ha2itat:restart"


  task :link_files do
    on roles(:app) do
      unless remote_link_exists?(fetch(:nginx_config))
        sudo :ln, "-s #{current_path.join("config/nginx.conf")} #{fetch(:nginx_config)}"
      end

      unless remote_link_exists?(fetch(:init_file))
        sudo :ln, "-s #{current_path.join("config/init.sh")} #{fetch(:init_file)} "
      end
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
      within release_path do
        execute :bundle, "exec ruby vendor/gems/ha2itat/bin/generate_js.rb"
        execute :npm, "install --legacy-peer-deps" # &> /dev/null"
        execute :npm, "run production"
      end
    end
  end

  before "deploy:cleanup", "ha2itat:npm_install"


  task :checkout do
    on roles(:app) do
      within release_path.join("vendor/gems") do
        execute :git, "clone #{fetch(:ha2itat_repo)} ha2itat"

      end
    end
  end

  before "bundler:config", "ha2itat:checkout"

  task :setup do;  end
  # before "ha2itat:setup", "ha2itat:link_files"
  after "ha2itat:link_media", "ha2itat:link_files"

end
