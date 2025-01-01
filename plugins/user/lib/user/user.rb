require_relative "database"
require "bcrypt"

module Plugins
  module User

    DEFAULT_ADAPTER = :File

    class Groups < Array

      def self.groups
        @groups ||= []
      end

      def self.to_group_cls(str)
        cs = str.to_s.capitalize
        if str.kind_of?(String) and str.include?("::")
          TOPLEVEL.const_get(cs)
        else
          Groups.const_get(cs)
        end
      end

      def =~(grpls)
        grpconst = Groups.to_group_cls(grpls)
        include?( grpconst  ) and grpconst
      end

      def self.to_a
        @groups
      end


      class UserGroup
        def self.inherited(cls)
          Groups.groups.push(cls)
        end

        def self.to_s
          name.to_s.split("::").last.downcase
        end
      end

      class Default < UserGroup
      end

      class Admin < UserGroup
      end

      def initialize(grps = [])
        push(*grps)
      end

    end

    class User

      include BCrypt

      Attributes = {
        :name        => String,
        :email       => String,
        :password    => String,
        :user_id     => String
      }

      attr_reader *Attributes.keys
      attr_accessor :password

      OptionalAttributes = []


      def self.filename(usr)
        us = usr.kind_of?(User) ? usr.name : usr
        "%s%s" % [ us.strip.gsub(' ', '-').gsub(/[^\w-]/, ''), ::Plugins::User::Database::Adapter::File::USERFILE_EXTENSION ]
      end

      def initialize
      end

      def add_to_group(grpcls)
        groups.push(grpcls)
      end

      def groups
        @groups ||= Groups.new
      end

      def admin?
        is_grouped? and groups.include?(Plugins::User::Groups::Admin)
      end

      def is_grouped?
        instance_variable_get("@groups")
      end

      def part_of?(grp)
        grp = Groups.const_get(grp.to_s.capitalize) if grp.kind_of?(String) or grp.kind_of?(Symbol)

        is_grouped? and groups =~ grp and true
      end

      def id
        user_id
      end

      def ==(obj)
        id == obj
      end

      def token
        token = JWT.encode({ :password => password, :user_id => id }, Ha2itat.quart.secret, 'HS256')
      end

      def populate(param_hash)
        password_submitted = [param_hash[:password], param_hash[:password1]].all?
        if password_submitted
          param_hash.delete(:password1)
          @password = Password.create(param_hash.delete(:password))
        end

        @user_id = Ha2itat::Database.get_random_id unless param_hash[:user_id]

        params = {}

        [:name, :email].each do |attrib|
          params[attrib] = param_hash[attrib]
        end

        groups = param_hash.delete(:groups)
        if groups
          groups_to_write = Groups.new
          groups.each_pair {|gn, gv|
            groups_to_write.push(Groups.to_group_cls(gn))
          }
          params[:groups] = groups_to_write
        end

        params.each_pair do |attrib, value|
          raise "user attrib #{attrib} unset" unless value
          instance_variable_set("@#{attrib}", value)
        end
        self
      end

      def authenticate(pw)
        Password.new(self.password) == pw and self
      end

      def filename
        User.filename(self)
      end

      def to_s
        '[%s  %s <%s> "%s"]' % [id, name, email, token]
      end

    end
  end
end
