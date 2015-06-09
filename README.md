# AwesomeChat Server
This is the server for the AwesomeChat chat application. It was developed and tested using Ruby v2.2.2.

## Setup
`git clone https://github.com/bodymindarts/awesomechat-server.git`

`bundle install`

Start Redis on localhost

`brew install redis`

`redis-server /usr/local/etc/redis.conf`

Run tests

`bundle exec rspec`

## Run the server
`bin/server`
