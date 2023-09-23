#!/usr/bin/env ruby

require "bundler/setup"

require "dry/cli"
require "dry/inflector"

require "hanami"
require_relative "../ha2itat"

require_relative "../mixins/fileutils"

module Ha2itat
  module Generator
  end

  module CLI
    module Commands
      extend Dry::CLI::Registry

      module Generate

        GET_ARGUMENTS = ->(i){
          argument :mod, desc: "modulename", require: true
          argument :clz, desc: "actionname", require: true
        }


        class ActionViewTemplate < Dry::CLI::Command
          instance_eval(&GET_ARGUMENTS)
          desc "generates view, controller and template package"

          def call(mod:, clz:, **options)
            [::Ha2itat::Generator::SliceAction.new(mod: mod, clz: clz),
             ::Ha2itat::Generator::SliceView.new(mod: mod, clz: clz),
             ::Ha2itat::Generator::SliceTemplate.new(mod: mod, clz: clz)].each do |generated|
              generated.write_to
            end
          end
        end

        class Slice < Dry::CLI::Command
          argument :name, desc: "slicename", require: true
          desc "generates slice"

          def call(name:, **options)
            ::Ha2itat::Generator::Slice.new(name: name).call
          end
        end

        class SliceAction < Dry::CLI::Command
          instance_eval(&GET_ARGUMENTS)
          desc "generates slice action"

          def call(mod:, clz:, **options)
            ::Ha2itat::Generator::SliceAction.new(mod: mod, clz: clz).write_to
          end
          #
        end

        class SliceView < Dry::CLI::Command
          instance_eval(&GET_ARGUMENTS)
          desc "generates slice view"

          def call(mod:, clz:, **options)
            ::Ha2itat::Generator::SliceView.new(mod: mod, clz: clz).write_to
          end

        end

        class SliceTemplate < Dry::CLI::Command
          instance_eval(&GET_ARGUMENTS)
          desc "generates slice template"

          def call(mod:, clz:, **options)
            ::Ha2itat::Generator::SliceTemplate.new(mod: mod, clz: clz).write_to
          end
        end

        class SliceHelper < Dry::CLI::Command
          argument :mod, desc: "modulename", require: true
          desc "generates slice helper file"

          def call(mod:, **options)
            ::Ha2itat::Generator::SliceHelper.new(mod: mod).write_to
          end
        end        

        class SliceSourceFile < Dry::CLI::Command
          argument :name, desc: "slicename", require: true
          desc "generates slice source file"

          def call(name:, **options)
            ::Ha2itat::Generator::SliceSourceFile.new(name: name).write_to
          end
        end
        
      end


      register "generate", aliases: ["g"] do |prefix|
        prefix.register "avw",      Generate::ActionViewTemplate
        prefix.register "slice",    Generate::Slice

        prefix.register "action",   Generate::SliceAction
        prefix.register "view",     Generate::SliceView
        prefix.register "template", Generate::SliceTemplate
        prefix.register "helper",   Generate::SliceHelper

        prefix.register "slicerb",  Generate::SliceSourceFile
      end
      
    end
  end

  module Generator
    ENTIRE_BLOCK = 'module Ha2itat::Slices
%s
end                      
'

    class ComponentFileGen
      attr_accessor :entire_block, :mod, :clz, :name

      include Ha2itat::Mixins::FU

      def initialize(**opts)
        opts.each_pair do |k, v|
          instance_variable_set("@%s" % k, v)
        end
      end

      def extension
        "rb"
      end

      def filename
        "%s.%s" % [clz||name||mod, extension]
      end
      
      def entire_block
        @entire_block ||= ENTIRE_BLOCK
      end

      def to_s
        entire_block % template % [inflector.classify(mod), inflector.classify(clz)]
      end

      def inflector
        @inflector ||= Dry::Inflector.new
      end

      def template
        @template ||= self.class::TEMPLATE
      end

      def write_to(target_path = Dir.pwd)
        target_filename = ::File.join(target_path, filename)
        if ::File.exist?(target_filename)
          Ha2itat.log("existing: #{target_filename}: skipping")
        else
          write(target_filename, to_s)
        end
      end
    end

    class Slice

      include Ha2itat::Mixins::FU

      class SliceMainAction < ComponentFileGen
        TEMPLATE = 'module Ha2itat::Slices::%s
  class Action < Hanami::Action
    instance_eval(&Ha2itat::CD(:action))
  end
end'
        def filename
          "action.rb"
        end

        def to_s
          template % inflector.classify(name)
        end
      end

      class SliceTemplateSubmenu < ComponentFileGen

        TEMPLATE = '.module-menu
  %%ul
    %%li= nlink(:backend_%s_index, "index")
'

        def filename
          "templates/_submenu.html.haml"
        end

        def to_s
          template % mod.to_s.downcase
        end

        
      end

      class SliceMainView < ComponentFileGen
        TEMPLATE = 'module Ha2itat::Slices::%s

  class View < Hanami::View
    config.paths = [Ha2itat.template_root, File.join(__dir__, "templates")]

    config.layouts_dir = Ha2itat.root("templates/layouts")
    config.layout = "backend"

    config.renderer_options = { escape_html: false }
  end
end
'
        def filename
          "view.rb"
        end

        def to_s
          template % inflector.classify(name)
        end
      end

      class SliceMainSlicerb < ComponentFileGen
        TEMPLATE = 'module Ha2itat::Slices::%s
  class Slice < Ha2itat::Slices::BackendSlice
    config.root = __dir__

    instance_eval(&Ha2itat::CD(:slice))
  end
end'
        def to_s
          template % inflector.classify(name)
        end

        def filename
          "slice.rb"
        end
      end

      class SliceMainConfigRoute < ComponentFileGen
        TEMPLATE = 'module Ha2itat::Slices::%s
  class Routes < Hanami::Routes
    get "/",           to: "index",   as: :index
  end
end'
        def filename
          "config/routes.rb"
        end

        def to_s
          template % inflector.classify(name)
        end
      end

      attr_reader :name, :clz

      def initialize(name:, clz: nil)
        @name = name
        @clz = clz
      end

      def collection
        @collection ||= {  }
      end

      def collect_component(comp)
        collection.merge!(comp.filename => comp)
        comp
      end

      def target_path
        @target_path ||= Dir.pwd
      end

      def write_collection_to(path)

        collection.each do |filename, c|
          complete_file = ::File.join(path, filename)
          directory = ::File.dirname(complete_file)
          mkdir_p(directory, verbose: false)
          write(complete_file, c.to_s)
        end
      end

      def call
        collect_component(SliceMainSlicerb.new(name: name))
        collect_component(SliceMainAction.new(name: name))
        collect_component(SliceMainView.new(name: name))
        collect_component(SliceMainConfigRoute.new(name: name))

        collect_component(SliceView.new(mod: name, clz: :index))
        collect_component(SliceAction.new(mod: name, clz: :index))
        collect_component(SliceTemplate.new(mod: name, clz: :index))
        collect_component(SliceTemplateSubmenu.new(mod: name, clz: :index))
        collect_component(SliceHelper.new(mod: name))

        write_collection_to(::File.join(target_path, "slice"))
      end
    end
    

    class SliceAction < ComponentFileGen
      TEMPLATE = '  module %s
    module Actions
      class %s < Action

        def handle(req, res)
          # res.render(view)
        end
      end
    end
  end'
      def filename
        ::File.join("actions", "#{clz}.rb")
      end
    end


    class SliceHelper < ComponentFileGen
      TEMPLATE = '
  module %s
    module Views
      module Helpers
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end'

      def filename
        ::File.join("views/helpers.rb")
      end
    end

 
    class SliceView < ComponentFileGen
      TEMPLATE = '  module %s
    module Views
      class %s < View
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end'

      def filename
        ::File.join("views", super)
      end
    end

    class SliceTemplate < ComponentFileGen
      TEMPLATE = ''
      def to_s
        "hello from #{mod}::#{clz}"
      end
      def filename
        ::File.join("templates", "#{clz}.html.haml")
      end
    end

  end
end


if __FILE__ == $0
  Dry::CLI.new(Ha2itat::CLI::Commands).call
end
