# Bramble [![Build Status](https://travis-ci.org/rmosolgo/bramble.svg?branch=master)](https://travis-ci.org/rmosolgo/bramble)

Map-reduce with ActiveJob

## Usage

- Setup ActiveJob with a queue named `:bramble`

- Setup Redis and give Bramble a connection object:

  ```ruby
  my_redis_connection = Redis.new # Your connection settings here!
  Bramble.config do |conf|
    conf.redis_conn = my_redis_connection
  end
  ```

- Define a module with `map` and `reduce` functions:

  ```ruby
  module LetterCount
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
  end
  ```

- Start a job with a handle, module, and some data:

  ```ruby
  # used for fetching the result later:
  handle = "shakespeare-letter-count"

  # Something that responds to #each:
  data = hamlet.split(" ")

  # Begin the process:
  Bramble.map_reduce(handle, LetterCount, words_in_hamlet)
  ```

- Later, fetch the result using the handle:

  ```ruby
  result = Bramble.read("shakespeare-letter-count")
  # { "A" => 100, "B" => 100, ... }
  ```

- Delete the saved result:

  ```ruby
  Bramble.delete("shakespeare-letter-count")
  ```

## Todo

- Use `Storage` as gateway to `config.storage`
- Job convenience class?
- `.fetch` to find-or-calculate?
- Adapters: Memcache, ActiveRecord

## Development

- `rake test`
