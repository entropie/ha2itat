def user_has_observed?(userid, cazeid)
  Ha2itat.adapter(:polygram).by_id(cazeid).done_by?(userid)
end

require_relative "polygram/case"
require_relative "polygram/observation"
require_relative "polygram/database"
