# frozen_string_literal: true

require "hanami"
require "ha2itat"

require_relative "h2-settings"

SESSION_KEY = '%%identifier%%.session'
SESSION_EXPIRY_TIME_IN_SECONDS = 60*60*24*365

module %%Identifier%%

  class App < Hanami::App

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

    instance_eval(&Ha2itat::CD(:slice))

  end
end


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

  plugs.generate_user_groups
end
Ha2itat::I18n.init

require_relative "h2-ext"
