module Plugins


  module Blog
    module BackendModuleInfo

      class Info
        def self.modules
          @modules ||= []
        end

        def self.inherited(o)
          modules << o
        end

        def initialize(post)
          @post = post
        end

        def ident
          self.class.to_s.split("::").last.downcase.gsub(/info$/, "")
        end

        def to_html
          "<div class='post-info mod#{ident} text-ellipsis'><strong>#{ident}</strong> <span>%s</span></div>"
        end

        def plugin_activated?(plug)
          Ha2itat.quart.plugins.activated?(plug)
        end
      end

      class UserInfo < Info
        def user
          @user ||= Ha2itat.adapter(:user).by_id(@post.user_id)
        end

        def to_html
          if Ha2itat.quart.plugins.enabled?(:user)
            super % user.name
          else
            ""
          end
        end
      end


      class VGWortInfo < Info

        def post
          @post.with_plugin(VGWort)
        end

        def to_html
          ret = ""
          return "" unless Plugins::Blog::VGWort.initialized?
          post_with_vgw = post.extend(Plugins::Blog::VGWort)

          if post_with_vgw.vgwort.id_attached?
            ret = "<code>#{post.vgwort.refid}</code>"
          else
            ret = "<span class='text-warning'>unset</span>"
          end
          super % ret
        end
      end


      class LanguagesInfo < Info

        def to_html
          langs = @post.languages
          return "" if langs.empty?
          super % langs.map {|l| "<a href='#{Backend.routes.post_path(@post.slug, l)}'>#{l}</a>"}
        end

      end

      class TemplateInfo < Info
        def to_html
          template = @post.template
          if template
            super % @post.template
          end
        end
      end

      class CharCounterInfo < Info
        def to_html
          text = @post.content.size
          super % text.to_s
        end
      end

    end
  end
end
