module Ha2itat::Slices::User
  class Action < Hanami::Action
    include ActionMethodsCommon

    include WardenCheckToken
    before :check_token
  end
end

