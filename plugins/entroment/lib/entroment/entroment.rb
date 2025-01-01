module Plugins
  module Entroment

    class Entry

      Attributes = {
        :created_at  => Time,
        :updated_at  => Time,
        :user_id     => String
      }

      OptionalFields = {
        :tags        => Array
      }

      attr_accessor :id
      attr_accessor :content
      attr_accessor *Attributes.keys
      attr_accessor *OptionalFields.keys

      def initialize(**params)
        parse_params(params)
      end

      def adapter(&blk)
        Ha2itat.adapter(:entroment).dup.with_user(user, &blk)
      end

      def parse_params(params)
        params.each_pair { |k,v|
          instance_variable_set("@%s"%k.to_s, v)
        }
      end

      def prepare_for_save
        remove_instance_variable("@user") rescue nil
        self.updated_at ||= created_at
        self.tags ||= []
        self.id
        self
      end

      def created_at
        @created_at ||= Time.now
      end

      def =~(idprob)
        id == idprob.to_s
      end

      def id
        @id ||= Ha2itat::Database::get_random_id(16)
      end

      def user
        @user ||= Ha2itat.adapter(:user).by_id(user_id)
      end

      def timeprefix
        created_at.strftime("%y/%m")
      end

      def yaml_filename
        "%s-%s.yaml" % [timeprefix, id]
      end

      def path(*args)
        adapter{ |a| ::File.join(a.user_path, *args) }
      end

      def filename
        path(yaml_filename)
      end

    end
  end
end
