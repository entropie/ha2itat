module Ha2itat::Slices::Blogtools
  class Action < Hanami::Action
    include ActionMethodsCommon
    before :check_token

    include Hanami::Action::Session


    def adapter
      Ha2itat.adapter(:blog)
    end
  end
end
