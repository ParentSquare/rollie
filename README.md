# Rollie

[![Build Status](https://travis-ci.org/zldavis/rollie.svg?branch=master)](https://travis-ci.org/zldavis/rollie)

Rollie is a multi-purpose, fast, redis backed rate limiter that can be used to limit requests to external APIs, in Rack
middleware, etc. Rollie uses a dedicated redis connection pool implemented using `connection_pool` for more efficient
redis connection management.
   
The key implementation detail is that Rollie utilizes a rolling window to bucket invocations in. Meaning, if you set
a limit of 100 per 30 seconds, Rollie will start the clock in instant it is first executed with a given key.
     
For example, first execution:
```
rollie = Rollie::RateLimiter.new("api", limit: 10, interval: 30000)
rollie.within_limit do
   puts Time.now
end
# => 2016-12-03 08:31:23.873
```

This doesn't mean the count is reset back to 0 at `2016-12-03 08:31:53.873`. Its a continuous rolling count, the count
is checked with every invocation over the last 30 seconds.
 
If you invoke this rate 9 times at `2016-12-03 08:31:53.500`, you will only be able to make one more call until `2016-12-03 08:32:23.500`. 

## Install

```
gem install rollie
```

## Usage

Rollie is simple to use and has only one method, `within_limit`. `within_limit` expects a block and that block will be
executed only if you are within the limit.

Initialize Rollie with a key used to uniquely identify what you are limiting. Use the options to set the limit and
interval in milliseconds.
```
# limit 30 requests per second.
twitter_rate = Rollie::RateLimiter.new("twitter_requests", limit: 30, interval: 1000)
status = twitter_rate.within_limit do
  twitter.do_something
end
```

The status will tell you the current state. You can also see the current count and how long until the bucket resets.
```
status.exceeded?
# => false
status.count
# => 1
status.time_remaining
# => 987 # milliseconds
```

Once exceeded:
```
status.exceeded?
# => true
status.count
# => 30
status.time_remaining
# => 461 # milliseconds
```  

You can also use a namespace if you want to track multiple entities, for example users.
```
Rollie::RateLimiter.new(user_id, namespace: "user_messages", limit: 100, interval: 30000)
```

## Configuration

By default Rollie will try to connect to redis using `ENV["REDIS_URL"]` if set or fallback to localhost:6379. You can
set an alternate redis configuration:
```
Rollie.redis = {
    url: CONFIG[:redis_url],
    pool_size: 5,
    pool_timeout: 1,
    driver: :hiredis
}
```

If using rails, create an initializer `config/initializers/rollie.rb` with these settings.