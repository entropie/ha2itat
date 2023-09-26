module Ha2itat::Slices

  module Blog
    module Views
      module Helpers
        instance_eval(&Ha2itat::CD(:view))

        def blog_author(post)
          Ha2itat::adapter(:user).by_id(post.user_id)
        end

        def templates_select(post)
          ""
        end

        def backend_module_info(post)
          quart = Ha2itat.quart
          ret = []

          Plugins::Blog::BackendModuleInfo::Info.modules.each do |infomod|
            clz = infomod.new(post)
            ret << clz.to_html.to_s
          end

          ret.join
        end

      end
    end
  end
end                      
