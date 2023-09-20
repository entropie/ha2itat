module Ha2itat::Slices::User

  class View < Hanami::View
    config.paths = [Ha2itat.template_root, File.join(__dir__, "templates")]

    config.layouts_dir = Ha2itat.root("templates/layouts")
    config.layout = "backend"

    config.renderer_options = { escape_html: false }

    instance_eval(&Ha2itat::CD(:view))

    expose :user
  end

end
