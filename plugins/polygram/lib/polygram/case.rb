module Plugins
  module Polygram


    class Case
      class CaseVariables < Hash
        def merge_from_input(**param_hash)
          user = param_hash.delete(:user)
          user ||= Ha2itat.adapter(:user).by_id(param_hash.delete(:user_id))

          self.merge(user_id: user.id).merge(**param_hash)
        end
      end

      attr_reader :user, :id, :variables

      def initialize(**param_hash)
        @variables = CaseVariables.new.merge_from_input(**param_hash)
        @id = Ha2itat::Database.get_random_id
      end

      def adapter
        @adapter ||= Ha2itat.adapter(:polygram)
      end

      def path(*args)
        adapter.case_path(id, *args)
      end

      def user
        Ha2itat.adapter(:user).by_id(variables[:user_id])
      end
    end

  end
end

