#!/usr/bin/env ruby

require_relative "../lib/ha2itat"
require File.join(Dir.pwd, "config/app.rb")

require "haml"

h2 = Ha2itat.quart = Ha2itat.quart_from_path(Dir.pwd)

require "hanami"


module Hanami
  module Utils
    module Escape
      class SafeString
        def replace(o)
          ""
        end
      end
    end
  end
end


SOURCE_MEDIA = "~/Source/habitat/quarters/fluffology/media/"


module Blog
  class Post
    attr_accessor :title, :slug, :created_at, :updated_at, :tags, :image, :template, :user_id, :filename, :datadir, :content

    def image
      @image
    end

    def image_path
      File.expand_path(File.join(SOURCE_MEDIA, "data", @image.dirname))
    end

    def image
      canditates = Dir.glob("%s/*.*" % [image_path])
      canditates.reject!{|c| File.extname(c) == ".webp"}
      Image.new(canditates.first)
    end

    def datadir(*args)
      File.expand_path(File.join(SOURCE_MEDIA, @datadir, *args))
    end

    def content
      file = datadir("content.markdown")
      File.readlines(file).join
    end

    def vgwort
      file = File.readlines(datadir(".vgwort"))
      img, code, id = file
      img, id = [img, id].map(&:strip)
      [img.scan(/(https?:\/\/\S+?)(?:[\s)]|$)/i).flatten.first, id]
    end


    def to_hash
      {
        created_at: @created_at,
        updated_at: @updated_at,
        slug: @slug,
        tags: @tags,
        title: @title,
        content: content
      }
    end

    module Utils
      module Escape
        module SafeString
        end

      end

    end

  end
  class Draft
  end

  class Image
    attr_accessor :basename, :dirname
    attr_accessor :path
    def initialize(path)
      @path = path
    end
  end

end

user = Ha2itat.adapter(:user).by_name("Anna Pietschmann")
target = Ha2itat.adapter(:blog).with_user(user)

files_glob = "/home/mit/Data/quarters/media/fluffology/blog/posts/*.yaml"

files = Dir.glob(files_glob)

test = files.first

loader = -> (file) {
  Psych.load(File.readlines(file).join,
             permitted_classes: [Blog::Post, Blog::Image, Time, Blog::Draft, Hanami::Utils::Escape::SafeString],
             aliases: true)
}

files.each do |file|
  tf = loader.call(file)
  tfh = tf.to_hash
  updated_at = tfh.fetch(:updated_at)

  post = target.update_or_create(tfh)

  target.upload(post, File.open(tf.image.path))
  target.store(post, updated_at: "foo")

  post.with_plugin(Plugins::Blog::VGWort).vgwort.write(*tf.vgwort)
end


# target.posts.each do |post|
#   target.to_post(post)
# end
