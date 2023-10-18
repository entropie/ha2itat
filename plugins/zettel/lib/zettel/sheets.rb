module Plugins
  module Zettel

    class Sheets < Array

      attr_accessor :user

      def initialize(u)
        @user = u
        super()
      end

      def [](pid)
        result = dup.select{|sheet| sheet == pid }
        result.shift if result.size == 1
      end

      def by_last_edited
        Sheets.new(@user).push(*dup.sort_by{|s| s.updated_at }.reverse)
      end

      def include?(other_or_id)
        tid = other_or_id.kind_of?(Sheet) ? other_or_id.id : other_or_id
        dup.reject{|s| s.id != tid}.size == 1
      end

      def by_reference_sorted(rfrnc)
        ref = References.normalize_key(rfrnc)
        by_refs = by_reference(rfrnc).sort_by{|r| r.title == ref ? 0 : 1}
        ret = Sheets.new(user)
        return [] if by_refs.empty?
        if by_refs.first.title == ref
          ret.push(by_refs.shift)
        end
        ret.push(*by_refs.sort_by{|br| br.title })
        ret
      end

      def by_reference(rfrnc)
        ref = References.normalize_key(rfrnc)
        select{|s| s.references.include?(ref) }
      end
    end

    class DMedia
      attr_accessor :sheet
      attr_accessor :user
      attr_accessor :filename

      def initialize(sheet, filename)
        @filename = filename
        @sheet = sheet
      end

      def http_path
        @sheet.http_path(filename)
      end

      def virtual_path
        @sheet.virtual_path(filename)
      end

      def path
        @sheet.data_dir(filename)
      end

      # def to_html
      #   '<img src="%s" />' % http_path
      # end

      def to_html
        '<span data-filename="%s" data-url="%s">%s</span>' % [filename, http_path, "<img src='#{http_path}'/>"]
      end
    end

    class Sheet
      Attributes = {
        :created_at  => Time,
        :updated_at  => Time,
        :user_id     => String
      }

      OptionalAttributes = [:title]

      attr_accessor :user
      attr_accessor :id
      attr_accessor :title
      attr_accessor :preview
      attr_accessor :content
      attr_accessor :file

      attr_accessor *Attributes.keys

      def filter_uploads(upload_files)
        filtered = upload_files.dup.reject{|uf| [".markdown", ".yaml"].include?(::File.extname(uf))}
        filtered
      end

      def uploads
        files = Dir.glob("%s*.*" % File.join(data_dir, "/"))
        files = filter_uploads(files)
        files.map{|f| DMedia.new(self, File.basename(f))}
      end

      def initialize(content = nil)
        @content = content
      end

      def title
        @title.to_s.size == 0 ? id : @title
      end

      def ==(sheet)
        id == sheet.id
      end

      def =~(obj)
        if obj.kind_of?(String)
          title == obj or @id == obj
        else
          false
        end
      end

      def time_to_path
        (@created_at || Time.now).strftime("%Y/%m/").split("/")
      end

      def user
        @user ||= Ha2itat.adapter(:user).by_id(@user_id)
      end

      def populate(param_hash)
        param_hash.each do |attribute, value|
          if respond_to?("#{attribute}=")
            instance_variable_set("@#{attribute}", value)
          else
            warn "#{attribute} ignored"
          end
        end
        self
      end

      def valid?
        missing = []
        Attributes.each do |attribute, attribute_type|
          next if OptionalAttributes.include?(attribute)

          if not var = instance_variable_get("@#{attribute}")
            missing << attribute
          elsif not var.kind_of?(attribute_type)
            missing << attribute
          else # pass
          end
        end
        not missing.any?
      end

      def exist?
        ::File.exist?(adapter.path(markdown_file))
      end

      def references
        @references ||= References.new(self)
      end

      def markdown_file
        adapter.markdown_file_for(self)
      end

      def path(*args)
        adapter.realpath(adapter.relative_path_for(self), *args)
      end

      def filename
        "sheet.markdown"
      end

      def content
        @content ||= File.readlines(adapter.realpath(markdown_file)).join rescue ""
      end

      def to_html
        Ha2itat::Renderer.render(:markdown, content)
      end

      def to_s
        content
      end

      def file
        path(filename)
      end

      def adapter
        Ha2itat.adapter(:zettel).with_user(user)
      end

      def directory(*args)
        ::File.join(adapter.directory_for(self), *args)
      end

      def virtual_path(*args)
        ::File.join(adapter.relative_path_for(self), *args)
      end

      def virtual_file(*args)
        ::File.join(adapter.relative_path_for(self), *args)
      end

      def http_path(*args)
        File.join("/_zettel/data", id, *args)
      end

      def relative_data_dir(*args)
        virtual_path(*args)
      end

      def data_dir(*args)
        ::File.join(adapter.data_dir_for(self), *args)
      end

      def to_hash
        r = {
          :content => content,
          :created_at => @created_at.rfc2822,
          :updated_at => @updated_at.rfc2822,
          :user_id => @user_id,
          :id => @id,
          :references => references.resolve.map{|r| r.id },
          # :file => virtual_file
        }
        r.merge!(:title => @title) if @title
        r
      end

      def to_json
        to_hash.to_json
      end

      def domid
        "sheet-#{id[0..10]}" rescue "sheet-noid"
      end

    end

  end
end
