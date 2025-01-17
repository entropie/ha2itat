puts "hello from entroment testsuite"

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
      adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar1", "keke"])
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

  def test_remove_card_after_tag_update
    @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar111"])
      adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar111"])
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar111"])

      assert testentry.decks.size == 1
      newentry  = adapter.update(testentry, tags: [])

      assert newentry.decks.size == 0
    end
  end

  def test_remove_card_after_tag_update_multiple
    @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS[1],             tags: ["deck:foobar111", "deck:kekelala123"])
      adapter.create(content: TESTCONTENTS[1],             tags: ["deck:foobar111", "deck:kekelala123"])
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar111", "deck:kekelala123"])

      assert testentry.decks.size == 2
      newentry  = adapter.update(testentry, tags: ["deck:kekelala123"])

      assert newentry.decks.size == 1
      exit
    end
  end



  def test_get_multiple_cards_for_entries
    testentry = @adapter.with_user(@user) do |adapter|
      adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar23", "deck:muh23", "keke"])
    end

    @adapter.with_user(@user) do |adapter|
      testentry = adapter.by_id(testentry.id)

      cards = adapter.cards_for(testentry)
      assert cards.size == 2
    end

  end

  def test_get_multiple_cards_for_entries_from_decks
    @adapter.with_user(@user) do |adapter|
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["deck:foobar1", "deck:muh1", "keke"])
      assert adapter.decks[:muh1].id_present?(testentry.id)
      assert adapter.decks[:foobar1].id_present?(testentry.id)
    end
  end


  def test_get_cards_from_entry
    @adapter.with_user(@user) do |adapter|
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["deck:keke11", "deck:fofof13"])
      assert testentry.cards.size == 2
    end
  end

  def test_get_decks_from_entry
    @adapter.with_user(@user) do |adapter|
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["deck:keke12"])
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["deck:keke12", "deck:fofof13"])
      assert testentry.decks.size == 2
    end
  end

  def test_case_update_existing_deck_with_tag
    @adapter.with_user(@user) do |adapter|
      testentry = adapter.create(content: TESTCONTENTS[1], tags: ["asd", "fsa"])

      loaded_entry = adapter.by_id(testentry.id)
      updated_entry = adapter.update(loaded_entry, tags: ["foo", "deck:muhahaha"])
      assert updated_entry.decks.size == 1
    end
  end

end


module Decksetup

  def decksetup(deckname = :sessiontest)
    retdeck = @adapter.with_user(@user){ |a| a.decks[deckname] }

    unless retdeck
      @adapter.with_user(@user) do |a|
        1.upto(40) do |i|
          newe = a.create(content: TESTCONTENTS[1] + " #{i}", tags: ["deck:#{deckname}"])
          card = newe.cards.first
          srand i
          newtime = Time.now - (rand(200)+10)*3600 + (60*rand(60)*rand(60))
          # Ha2itat.log("modulating date for #{card.id}")
          card.hash_to_instance_variables(last_reviewed: newtime)
          card.write
        end
        retdeck = a.decks[deckname]
      end
    end
    retdeck
  end


  def create_deck_with_custom_reviews(deckname = :sessiontest2)
    retdeck = @adapter.with_user(@user){ |a| a.decks[deckname] }

    unless retdeck
      adapter.with_user(@user) do |a|
        review_times = [24, 12, 36, 48, 6]
        review_times.each_with_index do |hours, index|
          content = "Content #{index + 1}"
          newe = a.create(content: content, tags: ["deck:#{deckname}"])
          card = newe.cards.first
          last_reviewed = Time.now - hours * 3600
          card.hash_to_instance_variables(last_reviewed: last_reviewed)
          card.write
        end
      end
    end
    retdeck
  end
end

class TestDeck < Minitest::Test
  include Decksetup
  def setup
    @adapter = Ha2itat.adapter(:entroment)
    @user    = Ha2itat.adapter(:user).user("test")
    @deck    = decksetup
  end

  def test_remove_entry_with_cards
    card = @deck.cards.first
    todelete_card_id = card.id
    entry = card.entry
    entry.destroy

    @deck.read
    assert_nil @deck.cards[todelete_card_id]
  end
end

class TestSession < Minitest::Test
  include Decksetup

  def setup
    @adapter = Ha2itat.adapter(:entroment)
    @user    = Ha2itat.adapter(:user).user("test")
    @deck    = decksetup
  end

  def test_standard_session
    session = @deck.new_session
    sspool = session.cards

    assert sspool.size == 20
    t1, t2 = *sspool.first(2)
    assert t2.next_due_time > t1.next_due_time
    assert @deck.session.id.kind_of?(String)
  end

  def test_custom_session_size
    newspool = @deck.new_session(length: 10).cards
    assert newspool.size == 10
  end

  def test_session_load
    session = @deck.new_session
    sessionid = session.id

    loaded_session = @deck.sessions[sessionid]

    assert loaded_session.kind_of?(Plugins::Entroment::Session)
    assert loaded_session.deck.kind_of?(Plugins::Entroment::Deck)
  end

  def test_session_loop
    session = @deck.new_session(length: 3)
    sessionid = session.id

    loaded_session = @deck.sessions[sessionid]

    loaded_session.transaction do |session|
      card = session.deal!
      assert session.cards.size == session.cardids.size
      assert session.cards.size == 2
      session.rate(card, 4)

      card = session.deal!
      assert session.cards.size == session.cardids.size
      assert session.cards.size == 1
      session.rate(card, 4)

    end
    assert loaded_session.cards.size == 1
    assert loaded_session.log.size == 2
  end

  def test_session_loop_with_wrong_ratings
    session = @deck.new_session(length: 3)
    sessionid = session.id

    loaded_session = @deck.sessions[sessionid]
    loaded_session.transaction do |session|
      card = session.deal!
      session.rate(card, 1)
    end
    assert loaded_session.cards.size == 3
    assert loaded_session.done_count == 1
    assert loaded_session.total_count == 4
    assert loaded_session.remaining_count == 3
    assert loaded_session.log.size == 1
  end

end


class TestDeck < Minitest::Test
  include Decksetup
  def setup
    @adapter = Ha2itat.adapter(:entroment)
    @user    = Ha2itat.adapter(:user).user("test")
    @deck    = decksetup
  end

  def test_session_rating_simple
    session = @deck.new_session(length: 3)

    ratings = [2,3,5]
    session.transaction do |session|
      0.upto(2) do |i|
        card = session.deal!
        session.rate(card, 5)

        assert session.session_score, ratings.unshift
      end
    end

  end


  def test_session_order
    session = @deck.new_session(length: 5)
    first_order = []
    5.times do
      card = session.deal!
      first_order << card.content
      session.rate(card, 3)
    end

    second_session = @deck.new_session(length: 5)
    second_order = []
    5.times do
      card = second_session.deal!
      second_order << card.content
      second_session.rate(card, 3)
    end

    assert_equal(first_order, second_order, "Die Kartenreihenfolge sollte konsistent sein")
  end

  def test_session_order_with_ratings
    session = @deck.new_session(length: 5)
    first_order = []
    5.times do
      card = session.deal!
      first_order << card.content
      session.rate(card, rand(1..5))
    end

    second_session = @deck.new_session(length: 5)
    second_order = []
    5.times do
      card = second_session.deal!
      second_order << card.content
      second_session.rate(card, rand(1..5))
    end

    refute_equal(first_order, second_order)
  end


  def test_session_order_with_specific_ratings
    session = @deck.new_session(length: 5)
    first_order = []
    ratings = [1, 3, 5, 2, 4]
    5.times do |i|
      card = session.deal!
      first_order << card.id
      session.rate(card, ratings[i])
    end

    second_session = @deck.new_session(length: 5)
    second_order = []
    5.times do
      card = second_session.deal!
      second_order << card.id
    end

    puts
    refute_equal(first_order, second_order)
  end
end


class SpacedRepetitionTestOrder < Minitest::Test
  include Decksetup

  def setup
    @adapter = Ha2itat.adapter(:entroment)
    @user    = Ha2itat.adapter(:user).user("test")
    @deck    = create_deck_with_custom_reviews(:testdeck2)
  end

  def test_card_order_based_on_ratings_and_last_reviewed
        session1 = @deck.new_session(length: 5)
    first_order = []
    ratings1 = [5, 2, 4, 3, 1]

    session1.transaction do |session|
      0.upto(4) do |i|
        card = session.deal!
        first_order << card.content
        session.rate(card, ratings1[i])
      end
    end

    session2 = @deck.new_session(length: 5)
    second_order = []
    ratings2 = [1, 3, 4, 2, 5]  # Potentially different ratings for second session

    session2.transaction do |session|
      0.upto(4) do |i|
        card = session.deal!
        second_order << card.content
        session.rate(card, ratings2[i])
      end
    end

    refute_equal(first_order, second_order, "Card order should change based on ratings given in the first session")
    assert_equal(second_order, session2.cards.sort_by(&:next_review_time).map(&:content), "Cards should be presented in order based on adjusted review times from ratings")
  end
end

