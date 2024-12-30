module Plugins
  module Entroment

    class Entry

      Attributes = {
        :created_at  => Time,
        :updated_at  => Time,
        :user_id     => String
      }

      attr_accessor :id
      attr_accessor :content
      attr_accessor *Attributes.keys
    end
  end
end
