# Bubot

Watch a method. If it takes longer than a specified amount of time,
execute a block. It's a callback that only happens after a threshold.

## Requirements

    ruby > 2.0.0

## Installation

Add this line to your application's Gemfile:

    gem 'bubot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bubot

## Usage

Include Bubot in your class.

This gives you the class method `.watch(:method_name, options)`.

If a watched method takes longer than options[:timeout], the block will execute.
Remember, the timeout is 0 by default so if you don't pass it a timeout, the
block will always execute (like an after callback).

Also, as a bonus, you get `.bubot`, which is syntactic sugar for active support callbacks.

### Example

```ruby
class WebAPI
  include Bubot

  watch(:response, timeout: 2) do |web_api_object, time_it_took, method_response|
    puts web_api_object   # => web_api_object instance
    puts time_it_took     # => 3.5 (seconds)
    puts method_response  # => "body"
  end

  def response
    sleep 3
    "body"
  end

  # Syntactic sugar for active support callbacks
  bubot :before, :save, :udpate
  bubot :around, :save, ->(instance, &block) { puts "Before"; block.call; puts "All Done" }
  bubot :after, :save do
    puts "Another thing to do after"
  end

  def save
    puts "Saving..."
  end

  def update
    puts "Updating..."
  end
end
```

You can also pass any object that responds to `call` by using the `:with`
option.

```ruby
class LoggingStrategy

  def self.call(web_api_object, time_it_took, method_response)
    puts web_api_object   # => web_api_object instance
    puts time_it_took     # => 5.2 (seconds)
    puts method_response  # => "body"
  end

end

class WebAPI
  include Bubot

  watch :response, timeout: 3, with: LoggingStrategy

  def response
    sleep 5
    "body"
  end
end
```
