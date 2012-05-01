# cube-ruby

A Cube client for Ruby (http://square.github.com/cube). Heavily based on
[this statsd ruby client](https://github.com/github/statsd-ruby).

MIT licensed. See https://github.com/codykrieger/cube-ruby/blob/master/LICENSE
for more details.

## Installation

Add this line to your application's Gemfile:

    gem 'cube-ruby', require: "cube"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cube-ruby

## Usage

### Set up a global Cube client

```ruby
# use default hostname and port of localhost:1180
$cube = Cube::Client.new

# use custom hostname and port
$cube = Cube::Client.new 'cube.example.org', 2280
```

### Send Cube some metrics!

```ruby
# send a new "foo" event to cube
$cube.send "foo"

# send a new event to cube that looks like this:
# { type: "request", time: [now], data: { value: "somevalue" } }
$cube.send "request", value: "somevalue"

# optionally specify a specific date/time (two days ago)
$cube.send "request", DateTime.now - 2, value: "othervalue"

# specify an event id (https://github.com/square/cube/wiki/Events)
event_id = 42
$cube.send "request", DateTime.now, event_id, duration_ms: 234
```

## Testing

Run the specs with `rake`.

To include real UDP socket testing in the specs, run `LIVE=true rake`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
