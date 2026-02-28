def user_has_observed?(userid, cazeid, mid)
  Ha2itat.adapter(:polygram).by_id(cazeid).observed_by?(userid, mid)
end

require_relative "polygram/case"
require_relative "polygram/observation"
require_relative "polygram/database"
