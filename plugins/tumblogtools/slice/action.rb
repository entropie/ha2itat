module Ha2itat::Slices::Tumblogtools
  class Action < Hanami::Action
    include ActionMethodsCommon
    before :check_token

    include Hanami::Action::Session


    def adapter
      Ha2itat.adapter(:tumblog)
    end
  end
end
