app_path = File.expand_path(File.join( File.expand_path(File.dirname(__FILE__)), "../../../../"))

$: << app_path
$: << File.join(app_path, "vendor/gems/ha2itat/lib")


require "config/app"

name, email, password = ARGV

group = Plugins::User::Groups::Admin

raise "#{$0} <name> <email> <password>" if not name or not password or not email

user = Ha2itat.adapter(:user).create(email:, name:, password:, password1: password)
user.add_to_group(group)
Ha2itat.adapter(:user).store(user)
