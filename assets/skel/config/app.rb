# frozen_string_literal: true

require "hanami"
require "ha2itat"

require_relative "h2-settings"

module %%Identifier%%

  class App < Hanami::App
    SESSION_KEY = '%%identifier%%.session'

    SESSION_EXPIRY_TIME_IN_SECONDS = 60*60*24*365

    config.logger.filters = config.logger.filters + ["token", "password1"]

    config.middleware.use Rack::MethodOverride

    config.middleware.use Warden::Manager
    config.middleware.use :body_parser, :form

    Ha2itat.quart.secret = SECRET = "%%SECRET%%"

    environment(:production) do
      config.logger.stream = root.join("log").join("production.log")
    end

    environment(:development) do
      config.logger.options[:colorize] = true
    end

    Ha2itat::I18n.init

    instance_eval(&Ha2itat::CD(:slice))

    Ha2itat.quart.plugins do |plugs|
      Ha2itat.log "loading plugins"

      plugs.register(:backend)
      plugs.register(:user)
      plugs.register(:snippets)
      plugs.register(:galleries)
      plugs.register(:icons)

      # plugs.register(:blog)
      # plugs.register(:tumblog)
      # plugs.register(:booking)
      # plugs.register(:zettel)
      # plugs.register(:notifier)
      # plugs.register(:bagpipe)

      plugs.write_javascript_include_file!
    end

    config.actions.sessions = :cookie, {
      key: SESSION_KEY,
      secret: SECRET,
      expire_after: SESSION_EXPIRY_TIME_IN_SECONDS
    }

  end
end




require_relative "h2-ext"
