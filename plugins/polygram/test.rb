puts "hello from polygram testsuite"

Ha2itat.quart.plugins.register(:polygram)
#Ha2itat.quart.plugins.write_javascript_include_file!

require "minitest/autorun"

# TESTCONTENTS = [
#   "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
#   "Lorem ipsum dolor sit amet, consectetur adipisicing elit --- sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
# ]

class TestCreate < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:polygram)
    @user    = Ha2itat.adapter(:user).user("test")
  end

  def test_create_wo_user
    p @adapter
  end
end

