module Ha2itat::Slices::Polygram

  class View < Hanami::View
    config.paths = [Ha2itat.template_root, File.join(__dir__, "templates")]

    config.layouts_dir = Ha2itat.root("templates/layouts")
    config.layout = "backend"

    config.renderer_options = { escape_html: false }

    expose :pager, :caze, :cases, :page, :complete, :menu, :media, :text, :observation, :reading, :errors, :activeMedia

  end
end
