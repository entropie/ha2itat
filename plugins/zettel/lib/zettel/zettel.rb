# coding: utf-8
#
#

require_relative "renderer"
require_relative "database"
require_relative "sheets"
require_relative "references"


module Plugins
  
  module Zettel

    DEFAULT_ADAPTER = :File
    
    class ZettelMappe < Array
    end
    
  end
end
