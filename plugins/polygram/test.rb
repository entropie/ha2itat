puts "hello from polygram testsuite"

Ha2itat.quart.plugins.register(:polygram)
#Ha2itat.quart.plugins.write_javascript_include_file!

require "minitest/autorun"

TESTFILES = [ "test/cases/a/video.mp4", "test/cases/b/video.mp4" ]

user = Plugins::User::User.new.populate(name: "test1", email: "test1@te.st", password: "test1")
user.add_to_group(Plugins::User::Groups.to_group_cls("default"))
Ha2itat.adapter(:user).store(user)

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
    caze = @adapter.create(user_id: @user, noop: true)
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

  def test_get_media_by_mid
    caze = @adapter.create(user_id: @user.id)
    @adapter.upload_for(caze, path: File.join(PLUGIN_PATH, TESTFILES.first))
    mid = caze.media.first.mid
    assert_kind_of Plugins::Polygram::Case::CaseMedia::Video, caze.media[mid]
  end

end


class TestCaseDocument < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:polygram)
    @user    = Ha2itat.adapter(:user).user("test")
    @user1   = Ha2itat.adapter(:user).user("test1")
    @caze    = @adapter.create(user_id: @user.id)
    @adapter.upload_for(@caze, path: File.join(PLUGIN_PATH, TESTFILES.first))
    @testmedia = @caze.media.first
  end

  def test_edit_not_existing_observation
    obs = @adapter.edit_observation(@caze, @testmedia.mid, @user, "observation text")
    assert_equal obs.mid, @testmedia.id
    assert_equal obs.text, "observation text"
  end

  def test_edit_not_existing_reading
    obs = @adapter.edit_reading(@caze, @testmedia.mid, @user, "reading text")
    assert_equal obs.mid, @testmedia.id
    assert_equal obs.text, "reading text"
  end

  def test_observations_from_case
    @adapter.edit_reading(@caze, @testmedia.mid, @user, "reading text")
    @adapter.edit_observation(@caze, @testmedia.mid, @user, "observation text")
    observations = @adapter.observations_for(@caze)
    assert_equal observations.size, 1
  end

  def test_readings_from_case
    @adapter.edit_reading(@caze, @testmedia.mid, @user, "reading text")
    @adapter.edit_observation(@caze, @testmedia.mid, @user, "observation text")
    readings = @adapter.readings_for(@caze)
    assert_equal readings.size, 1
  end

  def test_multiple_readings_from_case
    @adapter.edit_reading(@caze, @testmedia.mid, @user, "reading text")
    @adapter.edit_reading(@caze, @testmedia.mid, @user1, "reading text")
    readings = @adapter.readings_for(@caze)
    assert_equal readings.map(&:user).uniq.size, 2
    assert_equal readings.size, 2
  end

  def test_multiple_readings_and_user
    @adapter.edit_reading(@caze, @testmedia.mid, @user, "reading text")
    @adapter.edit_observation(@caze, @testmedia.mid, @user, "reading text")
    @adapter.edit_reading(@caze, @testmedia.mid, @user1, "reading text")
    @adapter.edit_observation(@caze, @testmedia.mid, @user1, "reading text")
    readings = @adapter.readings_for(@caze)
    assert_equal readings.map(&:path).uniq.size, 2
    observations = @adapter.observations_for(@caze)    
    assert_equal observations.map(&:path).uniq.size, 2
  end

  def test_reading_and_observation_set
    @adapter.edit_reading(@caze, @testmedia.mid, @user, "reading text")
    @adapter.edit_observation(@caze, @testmedia.mid, @user, "reading text")
    assert_equal @adapter.reading_and_observation_set_for(@caze, @testmedia.mid, @user1).size, 2
  end
end


class TestListCases < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:polygram)
    @user    = Ha2itat.adapter(:user).user("test")
    @user1   = Ha2itat.adapter(:user).user("test1")

    @cases = []
    0.upto(5) do |i|
      caze = @adapter.create(user_id: @user.id)
      testmedia = @adapter.upload_for(caze, path: File.join(PLUGIN_PATH, TESTFILES.first))

      @adapter.edit_reading(caze, testmedia.mid, @user, "user reading text")
      @adapter.edit_observation(caze, testmedia.mid, @user, "reading text")
      @adapter.edit_reading(caze, testmedia.mid, @user1, "other reading text")
      @adapter.edit_observation(caze, testmedia.mid, @user1, "other reading text")
      @cases << caze
    end
  end

  def test_get
    @cases.each do |caze|
      assert_equal 2, @adapter.readings_for(caze).size
      assert_equal 2, @adapter.observations_for(caze).size
    end
  end
end

