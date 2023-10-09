SETTING_HASH = {
  full_web_address: "https://staging.wecoso.de",
  pager_max: 10,
  page_prefix: "/s",
  blog_use_templates: true,
  author: "Not (lazy) Set",
  host: "https://staging.wecoso.de",
  title: "not set",
  desc: "not set",
  # bagpipe_root: "~/music",

  notifier: {
    mail: {
      to: Ha2itat.quart.development? ? "foobar" : "foobar",
      from: "foobar@gmail.com",
      cc: "foobar@gmail.com",
      via: "smtp",
      via_options: {
        address:              'smtp.gmail.com',
        port:                 '587',
        user_name:            "foobar",
        password:             "barfoo",
        authentication:       :plain
      }
    }
  }
}
