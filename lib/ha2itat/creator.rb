require 'sshkit'
require 'sshkit/dsl'

module Ha2itat
  module Creator

    def self.environment
      @environment ||= {}
    end

    def self.set_environment(hsh)
      environment.merge!(hsh)
    end

    class Command
      attr_accessor :command, :path
      attr_reader   :result

      def initialize(cmd)
        self.command = cmd
      end

      def run(cmd = nil)
        @command ||= cmd
        @command = command_with_path_or_not(@command)
        puts "> `#{command}'"
        system "#{command}"
      end

      def exist?(subpath = "")
        ::File.exist?( ::File.join( *[path, subpath].compact ))
      end

      def command_with_path_or_not(cmd)
        "%s%s" % [!path.nil? ? "cd #{path} && " : "", cmd]
      end

      def self.in(path)
        ret = new(nil)
        ret.path = path
        ret
      end

    end

    class RemoteCommand < Command
      include SSHKit::DSL

      def self.host=(hostname)
        @hostname = hostname
      end

      def self.host
        @hostname || ENV["H2_HOSTNAME"]
      end

      def host
        RemoteCommand.host
      end

      def exist?(subpath = "")
        run("if [ -e #{subpath} ]; then echo 'true'; fi").result == "true"
      end

      def run(cmd = nil)
        @command ||= cmd
        raise "self.command is nil" unless @command
        cmd = command_with_path_or_not(@command)
        puts "> #{host}: `#{cmd}'"
        result = nil
        on host do
          result = capture(cmd)
        end
        @result = result
        puts result
        self
      end
    end


    class File
      include Ha2itat::Mixins::FU

      attr_reader :path, :target

      def initialize(path, target)
        @path = path
        @target = target
      end

      def skel_file
        Ha2itat.root("assets/skel").join(@path)
      end

      def target_file
        ::File.join(target, path)
      end

      def copy
        return self if ::File.directory?(skel_file)
        directory = ::File.dirname(target_file)
        mkdir_p(directory) unless ::File.exist?(directory)
        cp(skel_file, target_file)
        self
      end

      def replace(what, with)
        return self if ::File.directory?(skel_file)
        contents = ::File.readlines(target_file)
        replaced_contents = contents.map {|c| c.gsub(what, with) }
        ::File.open(target_file, "w+") { |fp| fp.puts(replaced_contents.join) }
        self
      end
    end

    class SkeletonFile < File
    end

    class App

      attr_accessor :target
      attr_reader   :name

      def initialize(name, target: Dir.pwd)
        @name = name
        @target = ::File.join(target, name)
      end

      def identifier
        @name.to_s
      end

      def dotfiles
        [".gitignore", ".ruby-version", "vendor/gems/.keep", "log/.keep"]
      end

      def skeleton_path
        Ha2itat.root.join("assets/skel")
      end

      def skeleton_files
        dfs = dotfiles.map{|df| skeleton_path.join(df).to_s}
        dfs + [skeleton_path].map{|d|
          Dir.glob(d + "**/*")
        }.flatten
      end

      def relative_skeleton_files
        skeleton_files.map{|sf| Ha2itat.S(sf).gsub("./assets/skel/", "")}
      end

      def run_list(*list, what: Command)
        list.each do |listcommand|
          what.new(listcommand).run
        end
      end

      # create entire app skel
      def do_create_app
        run_list("hanami new #{name} --skip-install",
                 "mkdir -p #{name}/vendor/gems",
                 "ln -s ~/Source/ha2itat #{name}/vendor/gems/ha2itat",
                 "ln -s #{::File.join(Creator.environment.fetch(:media_dir), name)} #{name}/media" )

        relative_skeleton_files.each do |rf|
          sf = SkeletonFile.new(rf, target).copy
          if rf == "config/app.rb"
            sf.replace(/%%SECRET%%/, SecureRandom.hex(64))
          end
          sf.replace(/%%identifier%%/, identifier)
          sf.replace(/%%Identifier%%/, identifier.capitalize)
        end

        run_list("cd #{name} && bundle install",
                 "ln -s ../vendor/gems/ha2itat/config/deploy.rb #{name}/config/deploy.rb",
                 "cd #{name} && rm app/templates/layouts/app.html.erb",
                 "cd #{name} && npm install --legacy-peer-deps --silent")
      end

      def do_git
        do_repos_git
        do_media_git
        do_git_init
      end

      # initialize git in source and connect it with freshly created remote bare repos
      def do_git_init
        raise "#{name} not existing in #{Dir.pwd}" unless Command.in(name).exist?
        raise "#{name}/.git already existing" if Command.in(name).exist?(".git")

        origin = "ssh://%s:/%s" % [RemoteCommand.host, ::File.join(Creator.environment.fetch(:source_dir), "#{name}.git")]

        ["git init",
         "git add .",
         "git remote add origin #{origin}",
         "git commit -am initial",
         "git push --set-upstream origin master"].each do |rc|
          Command.in(name).run(rc)
        end
      end

      # create remote bare repos as codebase for our repos
      def do_repos_git
        source_dir = Creator.environment.fetch(:source_dir)
        git_source_dir = "#{name}.git"
        if RemoteCommand.in(source_dir).exist?(git_source_dir)
          warn "skipping setup source dir: #{::File.join(source_dir, git_source_dir)}.git already existing"
        else
          RemoteCommand.in(source_dir).run("git init --bare #{git_source_dir}")
        end
      end

      # create remote bare repos (and initialized) repos on remote server
      def do_media_git
        media_dir = Creator.environment.fetch(:media_dir)
        git_dir = "#{name}.git"
        if RemoteCommand.in(media_dir).exist?(git_dir)
          warn "skipping setup media dir: #{::File.join(media_dir, git_dir)} already existing"
        else
          RemoteCommand.in(media_dir).run("git init --bare #{git_dir}")
          RemoteCommand.in(media_dir).run("git clone #{git_dir}")
          complete_path = ::File.join(media_dir, name)
          RemoteCommand.in(complete_path).run("mkdir -p public/assets && touch public/assets/.keep")
          RemoteCommand.in(complete_path).run("git add public && git commit -am 'initial'")
          RemoteCommand.in(complete_path).run("git push")

          origin = "ssh://%s:/%s" % [RemoteCommand.host, ::File.join(media_dir, "#{name}.git")]
          Command.in(media_dir).run("git clone #{origin}")
        end
      end

    end
  end
end
