module Ha2itat::Slices::TestSlice

  class View < Hanami::View
    config.paths = File.join(__dir__, "templates")

    config.layouts_dir = Ha2itat.root("templates/layouts")
    config.layout = "backend"

    config.renderer_options = { escape_html: false }
  end

end

