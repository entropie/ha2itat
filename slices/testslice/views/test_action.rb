# frozen_string_literal: true

module Ha2itat::Slices
  module TestSlice

    module Views
      class TestAction < Ha2itat::Slices::TestSlice::View
        expose :request
        expose :testa do |request|
          Ha2itat.root
        end
      end

    end
  end
end
