module ViewMethodsCommon

  def icon(...)
    Plugins::Icons.icon(...)
  end

end


module Plugins
  module Icons

    def self.get_default_adapter_initialized
      Plugins::Icons
    end

    def icon(which)
      ret = "<svg class='feather'>%s</svg>"
      use = "<use href='%s' />" % "#{Hanami.app["routes"].path(:icons_sprite)}##{which}"
      ret % use
    end
    module_function :icon

  end
end
