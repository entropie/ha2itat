module Ha2itat
  module Test

    TEST_QUART_DIR = "/tmp/ha2itattest"
    TEST_MEDIA_DIR = "/tmp/ha2itat-test-media"
    TEST_SOURCE_DIR = "/tmp"

    def self.create_test_app(name = :test)
      Ha2itat::Creator.
        set_environment(media_dir: TEST_MEDIA_DIR,
                        source_dir: TEST_SOURCE_DIR)

      FileUtils.rm_rf(TEST_QUART_DIR)

      FileUtils.mkdir_p(::File.join(TEST_MEDIA_DIR, "ha2itattest"))
      Dir.chdir( ::File.dirname(TEST_QUART_DIR) ) do
        c = Ha2itat::Creator::App.new("ha2itattest")
        c.do_create_app(true)
        c
      end
    end

  end
end
