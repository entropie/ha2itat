require_relative "database"
require_relative "images"
require_relative "post"
require_relative "module_info"
require_relative "filter"
require_relative "vgwort"
require_relative "templates"
require_relative "readapi"

module Plugins


  module Blog

    DEFAULT_ADAPTER = :File

    def self.template_path(*args)
      possible_template_directories =
        [Ha2itat.quart.media_path("templates"),
         Ha2itat.root("plugins/blog/assets/templates").to_s]

      possible_template_directories.each do |ptd|
        if ::File.exist?(ptd)
          @template_path = ptd
          return @template_path
        end
      end
      if not @template_path
        raise "no template path given or existing; looked in #{PP.pp(possible_template_directories, "")}"
      end
      ::File.join(@template_path, *args)
    end

    def self.template_path=(obj)
      @template_path = obj
    end

    module BlogControllerMethods

      def blog(*args, &blk)
        adapter(:blog).with_user(session_user, &blk)
      end

      def posts_sorted(*args, sort_by: -> (post) { post.created_at }, &blk)
        blog.posts(*args, blk).sort_by(&sort_by).reverse
      end

    end

    module BlogViewMethods
      def blog_author(post)
        Ha2itat::adapter(:user).by_id(post.user_id)
      end

      def backend_module_info(post)
        quart = Habitat.quart
        ret = []

        BackendModuleInfo::Info.modules.each do |infomod|
          clz = infomod.new(post)
          ret << clz.to_html.to_s
        end

        _raw ret.join
      end

    end

  end

end
