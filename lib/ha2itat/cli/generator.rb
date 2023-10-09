require_relative "../generator.rb"

module Ha2itat

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

    end
  end
  
end
