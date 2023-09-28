module Ha2itat::Slices

  module Blog
    module Views
      module Helpers
        instance_eval(&Ha2itat::CD(:view))

        def blog_author(post)
          Ha2itat::adapter(:user).by_id(post.user_id)
        end

        def templates_select(post)
          ret = "<select class='form-select' name='template'>%s</select>"
          options = []
      
          templates = Plugins::Blog.templates.map(&:last)
          
          options << "<option value='%s'>%s</option>" % ["", "(none)"]
          templates.each do |tmplinst|

            if post and post.template
              if tmplinst == post.template
                selected = " selected='selected' "              
              else
                selected = ""
              end
              options << "<option %s value='%s'>%s</option>" % [selected, tmplinst.identifier, tmplinst.identifier]

            else
              options << "<option value='%s'>%s</option>" % [tmplinst.identifier, tmplinst.identifier]
            end
          end

          ret % options.join
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
