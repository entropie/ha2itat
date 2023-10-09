# auto_register: false
# frozen_string_literal: true

require "hanami/view"

module %%Identifier%%
  class View < Hanami::View

    config.paths = Hanami.app.root.join("app/templates")
    config.layout = "app"

    config.renderer_options = { escape_html: false }

    expose :params

  end
end
