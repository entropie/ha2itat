module Ha2itat::Slices::Polygram
  module Views
    module Helpers
      instance_eval(&Ha2itat::CD(:view))

      def user_has_observed?(userid, cazeid, mid)
        Ha2itat.adapter(:polygram).by_id(cazeid).observed_by?(userid, mid)
      end

    end
  end
end
