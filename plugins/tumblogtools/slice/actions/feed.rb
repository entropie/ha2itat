require "builder"

module Rss
  def to_xml(&blk)
    xml = Builder::XmlMarkup.new(indent: 1)
    xml.rss version: "2.0", "xmlns:dc": "http://purl.org/dc/elements/1.1/" do
      # xml.stylesheet(type: "text/css", href: "#{C(:host)}/assets/screen-app.css")
      xml.channel do
        xml.title "b(l|ookmark)ing"
        xml.description "wecoso bloogmarks; things of the internet"
        xml.language "en-gb"
        xml.generator "ha2itat"
        xml.link Ha2itat.C(:host)
        xml.pubDate(Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")) #Time.now.rfc2822
        xml.managingEditor "mictro@gmail.com"
        xml.webMaster "mictro@gmail.com"
        yield xml
      end
    end
    xml.target!
  end

  def post_to_xml(builder, post)
    builder.item do
      builder.link ::File.join(Ha2itat.C(:host), "bm", post.id)
      builder.guid post.id
      builder.pubDate post.created_at.rfc2822
      post.tags.each do |posttag|
        builder.category posttag
      end
      builder.description do
        builder.cdata!(post.to_html&.strip)
      end
    end
  end

  end


module Ha2itat::Slices
  module Tumblogtools
    module Actions
      class Feed < Action

        include Rss

        format :xml

        def handle(req, res)
          tags = req.params[:fragments]&.split("/")&.grep(/^[\w-]+$/)

          posts = tumblog_posts(req, tags: tags)
          ret = to_xml do |xml|
            posts.sort_by {|p| p.created_at }.reverse.first(50).each do |post|
              begin
                post_to_xml(xml, post)
              end
            end
          end

          res.format = :xml
          res.body = ret
        end
      end
    end
  end
end
