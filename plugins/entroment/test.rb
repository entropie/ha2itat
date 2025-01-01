puts "hello entroment test"

Ha2itat.quart.plugins.register(:entroment)
#Ha2itat.quart.plugins.write_javascript_include_file!

require "minitest/autorun"

TESTCONTENTS = [
  "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
]

class TestCreateUserRelated < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:entroment)
    @user    = Ha2itat.adapter(:user).user("test")
  end

  def test_create_wo_user
    assert_raises(Ha2itat::Database::NoUserContext) {
      @adapter.create(content: TESTCONTENTS.first)
    }
  end

  def test_create_w_user
    b = @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS.first)
    end

    assert_equal b.id.size, 16
    assert_equal b.content, TESTCONTENTS.first
    assert_equal b.user_id, @user.id
    assert_equal b.user, @user
  end

  def test_created
    @adapter.with_user(@user) do |adpt|
      entry = adpt.create(content: TESTCONTENTS.first)
      created_id = entry.id
      lib_entry = adpt.by_id(created_id)
      assert_kind_of Plugins::Entroment::Entry, lib_entry
      assert ::File.exist?( ::File.join(adpt.repository_path(lib_entry.filename)) )
    end
  end

  def test_tags
    @adapter.with_user(@user) do |adpt|
      entry = adpt.create(content: TESTCONTENTS.first, tags: ["foo", "bar"])
      assert entry.tags.include?("foo")
    end
    
  end

  def test_edit
    testentry = @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS.first)
    end
    targetid = testentry.id

    @adapter.with_user(@user) do |adpt|
      entry = adpt.by_id(targetid)
      entry.content = "henlo world"
      eid = entry.id
      adpt.store(entry)
      assert adpt.by_id(eid).content, "henlo world"
    end
    
  end
end
