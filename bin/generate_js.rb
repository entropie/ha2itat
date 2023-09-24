app_path = File.expand_path(File.join( File.expand_path(File.dirname(__FILE__)), "../../../../"))

$: << app_path
$: << File.join(app_path, "vendor/gems/ha2itat/lib")


require "config/app"

