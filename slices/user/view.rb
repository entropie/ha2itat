module Ha2itat::Slices::User

  class View < Hanami::View
    config.paths = File.join(__dir__, "templates")

    config.layouts_dir = Ha2itat.root("templates/layouts")
    config.layout = "backend"

    config.renderer_options = { escape_html: false }

    expose :request
    expose :testa do |request|
      "variable from action from user"
    end

  end

end
