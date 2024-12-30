puts "hello entroment test"

Ha2itat.quart.plugins.register(:entroment)
#Ha2itat.quart.plugins.write_javascript_include_file!

require "minitest/autorun"


class TestMeme < Minitest::Test
  def setup
    @adapter = Ha2itat.adapter(:entroment)
  end

  def test_foo
    p @adapter
  end

  # def test_that_kitty_can_eat
  #   assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  # end

  # def test_that_it_will_not_blend
  #   refute_match /^no/i, @meme.will_it_blend?
  # end

  # def test_that_will_be_skipped
  #   skip "test this later"
  # end
end
