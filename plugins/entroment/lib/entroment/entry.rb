module Plugins
  module Entroment
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
        @id ||= newid!
      end

      def newid!
        @id = Ha2itat::Database::get_random_id(16)
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

      def exist
        Ha2itat.adapter(:entroment).exist?(filename)
      end

      def to_html(cls: "entroment-entry", collapsed: false, highlight: [])
        content_to_handle = content
        highlight = [highlight].flatten

        if content.include?("---")
          clss = [:front, :back]
          arr = [content.split("---")].flatten.map{ |cf| cf.strip }
          vh = Hash[clss.zip(arr) ]
          content_to_handle = clss.map{ |c|
            add = highlight.include?(c) ? " hl" : ""
            "<div class='card-side-%s#{add}'>%s</div>" % [c, vh[c]]
          }
        end

        content_to_handle =
          if collapsed
            [content_to_handle].flatten.first
          else
            [content_to_handle].flatten.insert(1, "<div class='spacer'><hr /></div>").join
          end

        html_content = Ha2itat::Renderer.render(:markdown, content_to_handle)
        "<div class='%s' id='%s'>%s</div>" % [cls, "ee-#{id}", html_content]
      end

      def short_content
        content.split("---").first
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

      def destroy
        adapter { |a| a.destroy(self) }
      end
    end
  end
end
    
