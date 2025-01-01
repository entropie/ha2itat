APP_PATH = File.expand_path(File.join( File.expand_path(File.dirname(__FILE__)), "../../.."))

$: << APP_PATH
$: << APP_PATH + "/lib"
#$: << File.join(APP_PATH, "vendor/gems/ha2itat/lib")

require "ha2itat"
require "lib/ha2itat/test"
require "lib/ha2itat/creator"

Ha2itat::Test::create_test_app if not ::File.directory?(Ha2itat::Test::TEST_QUART_DIR)

puts "_"*60

Dir.chdir(Ha2itat::Test::TEST_QUART_DIR)
$:.unshift Ha2itat::Test::TEST_QUART_DIR
Ha2itat.quart = Ha2itat::Quart.new(Ha2itat::Test::TEST_QUART_DIR)

require "config/app"


# generate test user
unless Ha2itat.adapter(:user).user("test")
  user = Plugins::User::User.new.populate(name: "test", email: "test@te.st", password: "test")
  user.add_to_group(Plugins::User::Groups.to_group_cls("default"))
  Ha2itat.adapter(:user).store(user)
end


puts "_"*60


