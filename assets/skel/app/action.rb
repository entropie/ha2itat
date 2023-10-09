# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module %%Identifier%%
  class Action < Hanami::Action
    include ActionMethodsCommon

    before :check_token

    include Ha2itat::Helper::Translation::Actions
  end
end
