module Ha2itat::Slices::User
  class Action < Hanami::Action
    include ActionMethodsCommon

    include Authentification
    before :check_token

  end
end

