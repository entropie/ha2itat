module Ha2itat::Slices::Tumblog

  class View < Hanami::View
    config.paths = [Ha2itat.template_root, File.join(__dir__, "templates")]

    config.layouts_dir = Ha2itat.root("templates/layouts")
    config.layout = "backend"

    config.renderer_options = { escape_html: false }

    expose :post, :pager, :posts, :content

  end
end
