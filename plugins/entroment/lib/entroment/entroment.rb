module Plugins
  module Entroment

    module EntromentAdapter
      def adapter(&blk)
        Ha2itat.adapter(:entroment).dup.with_user(user, &blk)
      end
    end

    def self.tagify(strorarr)
      return [] unless strorarr
      if strorarr.kind_of?(Array)
        return strorarr
      else
        strorarr.split(",").map{ |e| e.strip }.compact
      end
    end
    
    class Entry

      include EntromentAdapter

      Attributes = {
        :created_at  => Time,
        :updated_at  => Time,
        :user_id     => String
      }

      OptionalFields = {
        :tags        => Array
      }

      attr_accessor :id
      attr_accessor :content
      attr_accessor *Attributes.keys
      attr_accessor *OptionalFields.keys

      def initialize(**params)
        parse_params(params)
      end

      def parse_params(params)
        params.each_pair { |k,v|
          instance_variable_set("@%s"%k.to_s, v)
        }
      end

      def ==(other)
        self.id == other.id
      end

      def prepare_for_save
        remove_instance_variable("@user") rescue nil
        self.updated_at ||= created_at
        self.tags ||= []
        self.id
        self
      end

      def created_at
        @created_at ||= Time.now
      end

      def =~(idprob)
        id == idprob.to_s
      end

      def id
        @id ||= Ha2itat::Database::get_random_id(16)
      end

      def user
        @user ||= Ha2itat.adapter(:user).by_id(user_id)
      end

      def timeprefix
        created_at.strftime("%y/%m")
      end

      def yaml_filename
        "%s-%s.yaml" % [timeprefix, id]
      end

      def path(*args)
        adapter{ |a| ::File.join(a.user_path, *args) }
      end

      def complete_path
        ::File.join(Ha2itat.adapter(:entroment).repository_path, filename)
      end

      def filename
        path(yaml_filename)
      end

      def exist?
        Ha2itat.adapter(:entroment).exist?(filename)
      end

      def to_html(cls: "entroment-entry")
        html_content = Ha2itat::Renderer.render(:markdown, content)
        "<div class='%s' id='%s'>%s</div>" % [cls, "ee-#{id}", html_content]
      end

      def update(ohash)
        newhash = ohash.slice(:content, *OptionalFields.keys)
        parse_params(newhash)
        self
      end

      def to_hash
        { id: id,
          content: content,
          tags: tags,
          url: Hanami.app["routes"].path(:api_entroment_v1_api_fetch, id: id),
          created_at: created_at,
          updated_at: updated_at
        }
      end

      def tags
        Tags.from_array(*@tags)
      end

      def decked?
        (tags.prefixed || []).size > 0
      end

      def cards
        adapter { |a| a.cards_for(self) }
      end

      def decks
        cards.map{ |card|
          adapter{ |adptr| adptr.decks[card.deck.name] }
        }
      end

      def prefixed_tags
        tags.prefixed
      end
    end
  end
end
