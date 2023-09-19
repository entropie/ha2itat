module Ha2itat::Slices::Backend

  class Action < Hanami::Action
    include ActionMethodsCommon

    include WardenCheckToken
    before :check_token
  end

end

