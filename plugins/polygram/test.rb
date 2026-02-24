puts "hello from polygram testsuite"

Ha2itat.quart.plugins.register(:polygram)
#Ha2itat.quart.plugins.write_javascript_include_file!

require "minitest/autorun"

# TESTCONTENTS = [
#   "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
#   "Lorem ipsum dolor sit amet, consectetur adipisicing elit --- sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
# ]
#p Dir.pwd, Ha2itat::Source.join("foo")

PLUGIN_PATH = File.dirname(__FILE__)

class TestCreateCaseA < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:polygram)
    @user    = Ha2itat.adapter(:user).user("test")
  end

  def test_create_case_user_id
    caze = @adapter.create(user_id: @user.id)
    assert_equal caze.user.id, @user.id
  end

  def test_create_case_user
    caze = @adapter.create(user_id: @user)
    assert_equal caze.user.id, @user.id
  end

  # def test_create_case
  #   caze = @adapter.create(user_id: @user.id, media: File.join(PLUGIN_PATH, "test/cases/a/video.mp4"))
  #   # pp caze.class
  #   pp caze.path
  #   pp caze
  # end
end

