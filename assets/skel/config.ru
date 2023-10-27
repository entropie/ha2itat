# frozen_string_literal: true

require "hanami/boot"

use Rack::Static, root: "media/public", urls: [ "/data", "/assets" ]

run Hanami.app
