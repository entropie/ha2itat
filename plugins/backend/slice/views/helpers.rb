# auto_register: false
# frozen_string_literal: true

module Ha2itat::Slices
  module Backend
    module Views
      module Helpers
        instance_eval(&Ha2itat::CD(:view))
      end
    end
  end
end
