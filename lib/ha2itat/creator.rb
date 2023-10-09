module Ha2itat
  module Creator

    class Command
      def initialize(cmd)
        @cmd = cmd
      end

      def run
        puts "> `#{@cmd}'"
        system "#{@cmd}"
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

      def skeleton_files
        [Ha2itat.root.join("assets/skel")].map{|d|
          Dir.glob(d + "**/*")
        }.flatten
      end

      def relative_skeleton_files
        skeleton_files.map{|sf| Ha2itat.S(sf).gsub("./assets/skel/", "")}
      end

      def do_create
        Command.new("hanami new #{name} --skip-install").run
        Command.new("mkdir -p #{name}/vendor/gems").run
        Command.new("ln -s ~/Source/ha2itat #{name}/vendor/gems/ha2itat").run
        relative_skeleton_files.each do |rf|
          SkeletonFile.new(rf, target).copy.
            replace(/%%identifier%%/, identifier).
            replace(/%%Identifier%%/, identifier.capitalize)
        end
        Command.new("cd #{name} && bundle install").run

        Command.new("ln -s ~/Source/ha2itat/config/deploy.rb #{name}/config").run


        Command.new("cd #{name} && rm app/templates/layouts/app.html.erb").run
        # Command.new("cd #{name} && bundle exec hanami generate action pages.page").run
        # Command.new("cd #{name} && bundle exec hanami generate view   pages.page").run
        # Command.new("cd #{name} && bundle exec hanami generate action pages.index").run
        # Command.new("cd #{name} && bundle exec hanami generate view   pages.index").run
      end
    end
  end
end
