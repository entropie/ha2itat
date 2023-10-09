# auto_register: false
# frozen_string_literal: true

module %%Identifier%%
  module Views
    module Helpers
      instance_eval(&Ha2itat::CD(:view))

      if Ha2itat.quart.plugins.enabled?(:galleries)

        include Plugins::Galleries::GalleriesAccessMethods
        
      end

    end
  end
end
