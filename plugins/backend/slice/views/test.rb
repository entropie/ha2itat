# frozen_string_literal: true

module Ha2itat::Slices
  module Backend

    module Views
      class Test < View

        expose :request
        expose :testa do |request|
          "variable from action"
        end
      end
    end

  end
end
