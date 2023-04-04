Rollie
===========

[![Gem Version](https://badge.fury.io/rb/rollie.svg)](https://badge.fury.io/rb/rollie)
[![CI](https://github.com/ParentSquare/rollie/workflows/CI/badge.svg)](https://github.com/ParentSquare/rollie/actions?query=workflow%3ACI+branch%3Amaster)
[![Code Quality](https://app.codacy.com/project/badge/Grade/20f8a080aca5444cbdaebff3a4e7e702)](https://www.codacy.com/gh/ParentSquare/rollie/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ParentSquare/rollie&amp;utm_campaign=Badge_Grade)
[![Coverage Status](https://codecov.io/gh/ParentSquare/rollie/branch/master/graph/badge.svg?token=0I92PXGZCM)](https://codecov.io/gh/ParentSquare/rollie)
[![Online docs](https://img.shields.io/badge/docs-✓-green.svg)](https://www.rubydoc.info/github/ParentSquare/rollie)

Rollie is a multi-purpose, fast, Redis backed rate limiter that can be used to
limit requests to external APIs, in Rack middleware, etc. Rollie uses a
dedicated Redis connection pool implemented using `connection_pool` for more
efficient Redis connection management. The Redis algorithm was inspired by the
[rolling-rate-limiter](https://www.npmjs.com/package/rolling-rate-limiter) node
package.

The key implementation detail is that Rollie utilizes a rolling window to bucket
invocations in. Meaning, if you set a limit of 100 per 30 seconds, Rollie will
start the clock in instant it is first executed with a given key.

For example, first execution:

```ruby
rollie = Rollie::RateLimiter.new("api", limit: 10, interval: 30000)
rollie.within_limit do
   puts Time.now
end
# => 2016-12-03 08:31:23.873
```

This doesn't mean the count is reset back to 0 at `2016-12-03 08:31:53.873`. Its
a continuous rolling count, the count is checked with every invocation over the
last 30 seconds.

If you invoke this rate 9 times at `2016-12-03 08:31:53.500`, you will only be
able to make one more call until `2016-12-03 08:32:23.500`.

## Install

Add it to your `Gemfile`:

```ruby
gem 'rollie'
```

Or install it manually:

```sh
gem install rollie
```

Usage
-----------

Rollie is simple to use and has only one method, `within_limit`. `within_limit`
expects a block and that block will be executed only if you are within the
limit.

Initialize Rollie with a key used to uniquely identify what you are limiting.
Use the options to set the limit and interval in milliseconds.

```ruby
# limit 30 requests per second.
twitter_rate = Rollie::RateLimiter.new("twitter_requests", limit: 30, interval: 1000)
status = twitter_rate.within_limit do
  twitter.do_something
end
```

The status will tell you the current state. You can also see the current count
and how long until the bucket resets.

If you don't want to block the request but control what happens next:

```
# limit 30 requests per second.
twitter_rate = Rollie::RateLimiter.new("twitter_requests", limit: 30, interval: 1000)
status = twitter_rate.increase_counter # This will always count blocked regardless on how you initialized the class
if status.exceeded?
  # Do Something here
else 
  # Do something different
end
```

```ruby
status.exceeded?
# => false
status.count
# => 1
status.time_remaining
# => 987 # milliseconds
```

Once exceeded:

```ruby
status.exceeded?
# => true
status.count
# => 30
status.time_remaining
# => 461 # milliseconds
```

You can also use a namespace if you want to track multiple entities, for example
users.

```ruby
Rollie::RateLimiter.new(
  user_id,
  namespace: "user_messages",
  limit: 100,
  interval: 30000
)
```

### Counting blocked actions

By default, blocked actions are not counted against the callee. This allows for
the block to be executed within the rate even when there is a continuous flood
of action. If you wish to change this behaviour, for example to require the
callee to back off before being allowed to execute again, set this option to
true.

```ruby
request_rate = Rollie::RateLimiter.new(
  ip,
  namespace: "ip",
  limit: 30,
  interval: 1000,
  count_blocked: true
)
```

Configuration
-------------------

By default Rollie will try to connect to Redis using `ENV["REDIS_URL"]` if set
or fallback to localhost:6379. You can set an alternate Redis configuration:

```ruby
Rollie.redis = {
    url: CONFIG[:redis_url],
    pool_size: 5,
    pool_timeout: 1,
    driver: :hiredis
}
```

If using rails, create an initializer `config/initializers/rollie.rb` with these
settings.
