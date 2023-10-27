require "pony"

module Plugins
  module Notifier


    def self.get_default_adapter_initialized
      Plugins::Notifier
    end

    class NotificationError < ArgumentError; end

    def notify(...)
      default_notifier.notify(...)
    end
    module_function :notify

    def default_notifier=(obj)
      @default_notifier = obj
    end

    def self.select(notifier)
      available_mods = Notification.notify_modules
      ret = available_mods.select{|nm| nm.name.split("::").last.downcase == notifier.to_s }.first
      raise "#{notifier} not in list #{PP.pp(available_mods, "")}" unless ret
      ret
    end

    def default_notifier
      @default_notifier ||= Notification.notify_modules.first
    end
    module_function :default_notifier, :default_notifier=



    class Notification

      def self.app_subject(str)
        "[%s] #{str}" % [ URI(Ha2itat.C(:host)).hostname ]
      rescue
        str
      end

      def self.notify_modules
        @notify_modules ||= []
      end

      def self.inherited(obj)
        notify_modules << obj
      end

      def initialize
      end
    end

    class Notifier::Mail < Notifier::Notification

      MANDATORY_CONFIG_KEYS = [:to, :from, :via, :via_options]


      def self.mandatory_settings_check(settinghash)
        MANDATORY_CONFIG_KEYS.all?{|k| settinghash.include?(k) }
      end

      # Example Settings Hash
      # notifier: {
      #   mail: {
      #     to: Ha2itat.quart.development? ? "mictro@gmail.com" : "bar@googlemail.com",
      #     from: "bar@gmail.com",
      #     via: "smtp",
      #     via_options: {
      #       address:              'smtp.gmail.com',
      #       port:                 '587',
      #       user_name:            "yourmom",
      #       password:             "yourmomspasswordisjäger111",
      #       authentication:       :plain
      #     }
      #   }
      # }
      def self.notify(**kwargs, &blk)
        config_hash = Ha2itat.C(:notifier)[:mail]

        raise "settings config_hash not providing for #{self}" unless config_hash

        unless mandatory_settings_check(config_hash)
          raise "settings config_hash[:mail] missing mandatory keys #{MANDATORY_CONFIG_KEYS-config_hash.keys}"
        end

        complete_options = config_hash.merge(kwargs)

        complete_options[:subject] = app_subject(complete_options[:subject])

        raise "no subject" unless complete_options[:subject]
        raise "no body" unless complete_options[:body]

        mail = Pony.mail(complete_options)
      end
    end
  end
end
