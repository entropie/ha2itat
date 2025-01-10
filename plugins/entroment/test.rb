puts "hello entroment test"

Ha2itat.quart.plugins.register(:entroment)
#Ha2itat.quart.plugins.write_javascript_include_file!

require "minitest/autorun"

TESTCONTENTS = [
  "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
  "Lorem ipsum dolor sit amet, consectetur adipisicing elit --- sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",  
]

class TestCreate < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:entroment)
    @user    = Ha2itat.adapter(:user).user("test")
  end

  def test_create_wo_user
    assert_raises(Ha2itat::Database::NoUserContext) { @adapter.create(content: TESTCONTENTS.first) }
  end

  def test_read_wo_user
    assert_raises(Ha2itat::Database::NoUserContext) { @adapter.read }
  end

  def test_read_wo_user_by_id
    assert_raises(Ha2itat::Database::NoUserContext) { @adapter.by_id("123") }
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

  def test_find_by_content
    @adapter.with_user(@user) do |adpt|
      entry = adpt.create(content: "henlo")
      entryid = entry.id
      searched_entry = adpt.find(content: "henlo").any?{ |se|
        se.id == entryid
      }
      assert searched_entry
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
    ostamp = testentry.created_at
    assert_equal testentry.created_at, testentry.updated_at

    @adapter.with_user(@user) do |adpt|
      entry = adpt.by_id(targetid)
      entry.content = "henlo world"
      eid = entry.id
      adpt.store(entry)
      newentry = adpt.by_id(eid)
      assert newentry.content, "henlo world"
      assert newentry.updated_at != testentry.updated_at
    end
    
  end

  def test_context_edit
    testentry = @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS.first)
    end
    targetid = testentry.id

    @adapter.with_user(@user) do |adpt|
      entry = adpt.by_id(targetid)
      adpt.update(entry.dup, content: "henlo world", tags: ["foo", "bar"])
      newentry = adpt.by_id(targetid)
      assert entry.updated_at != newentry.updated_at
      assert_equal newentry.tags, ["foo", "bar"]
    end
  end

  def test_tags_ext
    testentry = @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS.first, tags: ["sr:foo", "bar"])
    end
    assert testentry.tags.kind_of?(Plugins::Entroment::Tags::Tags)
    assert testentry.tags.include?("sr:foo")
    assert testentry.tags.first.kind_of?(Plugins::Entroment::Tags::PrefixedTag)
  end

end


class TestDeck < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:entroment)
    @user    = Ha2itat.adapter(:user).user("test")
  end

  def test_get_create_card_when_create_entry
    testentry = @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar", "keke"])
    end

    @adapter.with_user(@user) do |adapter|
      card = adapter.cards_for(testentry).first
      assert_equal card.user, @user
      assert_equal card.entry, testentry
    end

    @adapter.with_user(@user) do |adapter|
      testentry = adapter.by_id(testentry.id)

      card = adapter.cards_for(testentry).first
      assert_equal card.user, @user
      assert_equal card.entry, testentry
    end

  end

  def test_get_decks
    @adapter.with_user(@user) do |adapter|
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["deck:keke"])
      assert adapter.decks[:keke].id_present?(testentry.id)
    end
  end
end
