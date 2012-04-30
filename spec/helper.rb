require 'minitest/autorun'

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

