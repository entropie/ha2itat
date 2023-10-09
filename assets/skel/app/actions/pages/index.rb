# frozen_string_literal: true

module %%Identifier%%
  module Actions
    module Pages
      class Index < Wecoso::Action
        def handle(req, res)
          res.render(view)
        end
      end
    end
  end
end
