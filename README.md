# Bubot

Take action when methods take too long

## Installation

Add this line to your application's Gemfile:

    gem 'bubot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bubot

## Usage

Extend Bubot in your class.

This gives you the class method `.watch(:method_name, threshold)`.

If a watched method takes longer than the specified amount of time (threshold), the block will execute.

```ruby
class Foo
    extend Bubot

    watch(:bar, 1) { run_some_code }

    def bar
        sleep 1.1
    end
end
```
