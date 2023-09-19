# frozen_string_literal: true

module Ha2itat::Slices
  module User

    module Views
      class Index < View

        expose :user do
          Ha2itat.adapter(:user).user.sort_by{ |u| u.name }
        end

      end
    end

  end
end
