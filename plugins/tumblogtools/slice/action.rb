module Ha2itat::Slices::Tumblogtools
  class Action < Hanami::Action
    include ActionMethodsCommon
    before :check_token

    include Hanami::Action::Session


    def adapter
      Ha2itat.adapter(:tumblog)
    end

    def tumblog_posts(req, tags: nil)
      posts = adapter.with_user(session_user(req)).entries.sort_by{|p| p.created_at }.reverse
      if not session_user(req)
        posts.reject!{ |pst| pst.private? }
      end

      if tags and not tags.empty?
        posts.reject!{ |pst| !pst.tags.any?{ |psttag| tags.include?(psttag) } }
      end
      posts
    end
  end
end
