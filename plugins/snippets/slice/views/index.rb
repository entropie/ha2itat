# frozen_string_literal: true

module Ha2itat::Slices
  module Snippets

    module Views
      class Index < View

        expose :pager
        expose :snippets

      end
    end
  end
end
