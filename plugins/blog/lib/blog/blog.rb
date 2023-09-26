require_relative "database"
require_relative "images"
require_relative "post"
require_relative "module_info"
require_relative "filter"
require_relative "templates"
require_relative "readapi"

module Plugins
  

  module Blog

    DEFAULT_ADAPTER = :File

    TEMPLATE_PATH = File.join(File.dirname(__FILE__), "../../templates")


    def self.template_path(*args)
      File.join(@template_path, *args)
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
