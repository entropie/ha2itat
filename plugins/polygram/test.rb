puts "hello from polygram testsuite"

Ha2itat.quart.plugins.register(:polygram)
#Ha2itat.quart.plugins.write_javascript_include_file!

require "minitest/autorun"

TESTFILES = [ "test/cases/a/video.mp4", "test/cases/b/video.mp4" ]

PLUGIN_PATH = File.dirname(__FILE__)

class TestCreateCaseBasics < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:polygram)
    @user    = Ha2itat.adapter(:user).user("test")
  end

  def test_create_case_user_id
    caze = @adapter.create(user_id: @user.id)
    assert_equal caze.user.id, @user.id
  end

  def test_create_case_class
    caze = @adapter.create(user_id: @user.id)
    assert_kind_of Plugins::Polygram::Case, caze
    assert_kind_of Plugins::Polygram::VideosCase, caze
  end

  def test_create_case_images
    caze = @adapter.create(user_id: @user.id, kind: :images)
    assert_kind_of Plugins::Polygram::Case, caze
    assert_kind_of Plugins::Polygram::ImagesCase, caze
  end

  def test_create_case_videos
    caze = @adapter.create(user_id: @user.id, kind: :videos)
    assert_kind_of Plugins::Polygram::Case, caze
    assert_kind_of Plugins::Polygram::VideosCase, caze
  end
  
  def test_create_case_user
    caze = @adapter.create(user_id: @user)
    assert_equal caze.user.id, @user.id
  end

  def test_create_case_should_not_exist
    caze = @adapter.create(user_id: @user)
    assert !caze.exist?
  end

  def test_case_paths
    caze = @adapter.create(user_id: @user)
    cpath = ::File.join(@adapter.repository_path, "cases", caze.id)
    assert_equal caze.path, cpath
    assert_equal caze.storage_path, ::File.join(cpath, "storage")
    assert_equal caze.relative_storage_path, ::File.join("cases", caze.id, "storage")
  end
end


class TestCreateCaseCreateVideo < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:polygram)
    @user    = Ha2itat.adapter(:user).user("test")
  end

  def test_upload_video
    caze = @adapter.create(user_id: @user.id)
    @adapter.upload_for(caze, path: File.join(PLUGIN_PATH, TESTFILES.first))
    assert_equal caze.media.size, 1
    assert_kind_of Plugins::Polygram::Case::CaseMedia::Video, caze.media.first
  end

  def test_upload_same_video
    caze = @adapter.create(user_id: @user.id)
    @adapter.upload_for(caze, path: File.join(PLUGIN_PATH, TESTFILES.first))
    @adapter.upload_for(caze, path: File.join(PLUGIN_PATH, TESTFILES.first))
    assert_equal caze.media.size, 1
  end


  def test_video_url
    caze = @adapter.create(user_id: @user.id)
    @adapter.upload_for(caze, path: File.join(PLUGIN_PATH, TESTFILES.first))
    bn = ::File.basename(caze.media.first.file)
    assert_equal caze.media.first.url, "/polygram/cases/%s/storage/%s" % [caze.id, bn]

  end
end
