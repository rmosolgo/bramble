# Bramble

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
    def self.map(word)
      letters = word.upcase.each_char  
      # `yield` to emit a key-value pair for processing
      letters.each { |letter| yield(letter, 1) }
    end

    def self.reduce(letter, observations)
      # Yielded values are grouped by key:
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
  words_in_hamlet = hamlet.split(" ")
  Bramble.map_reduce(handle, LetterCount, words_in_hamlet)
  ```

- Later, fetch the result using the handle:

  ```ruby
  Bramble.read("shakespeare-letter-count")
  # { "A" => 100, "B" => 100, ... }
  ```


## Todo

- Job convenience class?
- `.fetch` to find-or-calculate?
- Adapters: Memcache, ActiveRecord
