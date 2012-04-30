require 'minitest/autorun'

# yanked almost verbatim from here: https://github.com/github/statsd-ruby/blob/master/spec/helper.rb
# license: https://github.com/github/statsd-ruby/blob/master/LICENSE.txt

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'cube'
require 'logger'

class FakeUDPSocket
  def initialize
    @buffer = []
  end

  def send(message, *args)
    @buffer.push [message]
  end

  def recv
    res = @buffer.shift
  end

  def clear
    @buffer = []
  end

  def to_s
    inspect
  end

  def inspect
    "<FakeUDPSocket: #{@buffer.inspect}>"
  end
end

