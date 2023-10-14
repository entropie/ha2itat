require "builder"

module Rss
  def to_xml(&blk)
    xml = Builder::XmlMarkup.new(indent: 1)
    xml.rss version: "2.0", "xmlns:dc": "http://purl.org/dc/elements/1.1/" do
      # xml.stylesheet(type: "text/css", href: "#{C(:host)}/assets/screen-app.css")
      xml.channel do
        xml.title Ha2itat.C(:title)
        xml.description(Ha2itat.C(:desc), type: "html")
        xml.language "de-de"
        xml.generator "My Mom"
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
      builder.title post.title
      builder.author post.user.name
      builder.link ::File.join(Ha2itat.C(:host), "post", post.slug)
      builder.guid post.id
      builder.pubDate post.created_at.rfc2822
      # builder.description post.intro
      #builder.tag!("content:encoded", builder.cdata!(post.with_filter))
      builder.description "type" => "html" do
        builder.cdata!(post.with_filter)
      end
    end
  end

end


module Ha2itat::Slices
  module Blogtools
    module Actions
      class Feed < Action

        include Rss

        format :xml

        def handle(req, res)
          posts = adapter.posts
          ret = to_xml do |xml|
            posts.sort_by {|p| p.created_at }.reverse.first(10).each do |post|
              begin
                post_to_xml(xml, post)
              end
              xml.asd
            end
          end

          res.format = :xml
          res.body = ret

        end
      end
    end
  end
end
