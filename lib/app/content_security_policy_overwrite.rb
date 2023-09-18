class Hanami::Config::Actions::ContentSecurityPolicy

  def initialize(&blk)
    @policy = {
      base_uri: "'self'",
      child_src: "'self'",
      connect_src: "'self'",
      default_src: "'none'",
      font_src: "'self'",
      form_action: "'self'",
      frame_ancestors: "'self'",
      frame_src: "'self'",
      img_src: "'self' https: data:",
      media_src: "'self'",
      object_src: "'self' 'unsafe-eval'",
      script_src: "'self' 'unsafe-eval'",
      style_src: "'self' 'unsafe-inline' https:"
    }
    blk&.(self)
  end
end
