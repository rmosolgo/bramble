# Bramble [![Build Status](https://travis-ci.org/rmosolgo/bramble.svg?branch=master)](https://travis-ci.org/rmosolgo/bramble) [![Gem Version](https://badge.fury.io/rb/bramble.svg)](https://badge.fury.io/rb/bramble)

Map-reduce with ActiveJob + database

## Rationale

We have some staff-only views that expose stats about how people use our app. Eventually, our tables grew so large that MySQL wouldn't aggregate them all at once. So we can use this to generate those stats over time.

## Usage

- Setup ActiveJob with a queue named `:bramble`

- Setup Redis and give Bramble a connection object:

  ```ruby
  my_redis_connection = Redis.new # Your connection settings here!
  Bramble.config do |conf|
    conf.redis_conn = my_redis_connection
  end
  ```

- Define a module with `map`, `reduce` and `items(options = {})` functions:

  ```ruby
  module LetterCount
    # Generate a list of items based on some input
    def self.items(filepath)
      File.read(filepath).split(" ")
    end

    # .map is called with each item in the input
    def self.map(word)
      letters = word.upcase.each_char

      # call `yield` to emit a key-value pair for processing
      letters.each { |letter| yield(letter, 1) }
    end

    # .reduce is called with
    # - `yield` key (first argument)
    # - array of `yield` values (second argument)
    def self.reduce(letter, observations)
      # letter => "A"
      # observations => [1, 1, 1, 1, 1]
      observations.length
    end

    # If a .map or .reduce hits an error,
    # it will be rescued and passed here.
    # To cause the job to fail, raise it again.
    # Otherwise, let it pass
    def self.on_error(err)
      Bugsnag.notify(err)
      # Or, to trigger a faiure:
      # raise(err)
    end
  end
  ```

  Inputs and outputs are serialized with __JSON__, so some Ruby types will be lost (eg, Symbols).

- Start a job with a handle, module, and an (optional) argument for finding data:

  ```ruby
  # used for fetching the result later:
  handle = "shakespeare-letter-count"

  # will be sent to `.items(filepath)`
  hamlet_path = "./shakespeare/hamlet.txt"

  # Begin the process:
  Bramble.map_reduce(handle, LetterCount, hamlet_path)
  ```

- Later, fetch the result using the handle:

  ```ruby
  result = Bramble.get("shakespeare-letter-count")
  result.running?         # => false
  result.finished?        # => true
  result.data             # => { "A" => 100, "B" => 100, ... }
  result.percent_finished # 1.0
  result.percent_mapped   # 1.0
  result.percent_reduced  # 1.0
  result.finished_at      # 2016-05-16 12:31:00 UTC
  ```

- Delete the saved result:

  ```ruby
  Bramble.delete("shakespeare-letter-count")
  ```

## Todo

- Adapters: Memcached, ActiveRecord
- Warn if no storage is configured
- Do we have atomicity issues? Occasional test failures
- Consolidate storage in Redis to a single key? (Could some keys be evicted while others remain?)

## Development

- `rake test`
