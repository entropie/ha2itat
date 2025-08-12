# ha2itat: Hanami Application Management & Deployment

**ha2itat** is a dedicated tool designed to streamline the management
and deployment of @anami applications.

It features a versatile plugin system that can extend your application
with CMS-like capabilities and other sophisticated enhancements.

## Core Features

* **Plugin Architecture:** Easily extend your application with
  powerful plugins. This allows for the integration of CMS-like
  features and other complex functionalities, tailored to your needs.

* **Simplified Data Management:** All application data, specifically
  the data from all active plugins, is consolidated into a single
  `./media` directory. This directory is typically managed separately
  from the git repository and integrated via a symbolic link. This
  approach eliminates the need for a database setup.

* **Semi-Static File Serving:** Deliver semi-static template files,
  like Markdown, effortlessly from the frontend. Files are accessible
  via a straightforward URL structure (e.g.,
  `your-site.tld/s/your-markdown-file`).

* **Streamlined Deployment:** Applications are deployed to the server
  using [Capistrano](https://capistranorb.com/). The standard
  deployment path is versioned within
  `/home/ha2itats/APPLICATION_NAME`. This directory also contains the
  necessary sockets for the application to run. We do not rollback


### Plugins

* `blog` - A classic blog engine
* `booking` - A calendar, event, and booking system
* `galleries` - For creating and managing image galleries
* `notifier` -  Notifications
* `snippets` - Manage short text snippets for embedding on pages
* `user` - User and role management
* `bagpipe` - Provides basic access to a music library
* `entroment` - A spaced repetition learning tool. My latest creation, born out of desperation
* `simpledb` - A basic framework for inputting and managing various kinds of data
* `tumblog` - A microblogging tool that can also function as a data dump, a mirror for YouTube/Reddit, and more. I've been using it to manage my bookmarks for a while now
* `zettel` - A Zettelkasten-style system for creating interconnected notes using tags


### App-Structure
```
./app           # hanami anwendung
./config
  ./app.rb      # hanami app.definition and plugin selection;
  ./nginx.conf  # to be linked to
                # `/etc/nginx/sites-enabled/ha2-ANWENDUNGSNAME.conf`
  ./init.sh     # to be linked to `/etc/init.d` on init systems
./lib           # do your thing
./media         # DATA - symlink or mount
./vendor/gems/ha2itat # this repos
```  
  
### Workflow (roughly)

    $ git clone https://github.com/entropie/ha2itat.git
    $ cd ha2itat
    $ bundle install
    $ bin/h2 --help
    $ H2_HOSTNAME=yourservername.tld bin/h2 create foobar
    

### Docker: create

    $ git clone https://github.com/entropie/ha2itat.git
    $ cd ha2itat

    # $EDITOR Dockerfile.create 
    $ docker build --no-cache -f Dockerfile.create -t ha2-create .

    $ # generate admin user: `vendor/gems/ha2itat/bin/user.rb <name> <email> <password>'
    $ docker run -it --rm -v /tmp/ha2itat-media:/app/media ha2-create bundle exec ruby vendor/gems/ha2itat/bin/user.rb admin ad@mi.n foobar
    
    $ docker run -it --rm -v /tmp/ha2itat-media:/app/media -p 2300:2300 ha2-create overmind s
 
    $ open http://localhost:2300
    $ open http://localhost:2300/backend/user/login

##### Docker: Copy

    $ # docker create --name temp-ha2-test ha2-create; docker cp temp-ha2-test:/app /tmp/test; docker rm temp-ha2-test

