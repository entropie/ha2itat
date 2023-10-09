# frozen_string_literal: true

module %%Identifier%%
  class Routes < Hanami::Routes
    # root { "Hello from Hanami" }

    get "/",                      to: "pages.index", as: :index

    instance_eval(&Ha2itat.module_routes)

  end
end
