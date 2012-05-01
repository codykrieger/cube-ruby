$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'cube'

cube = Cube::Client.new
cube.send "testorz"

