require 'helper'
require 'date'
require 'json'

# a few things yanked verbatim from here: https://github.com/github/statsd-ruby/blob/master/spec/statsd_spec.rb
# license: https://github.com/github/statsd-ruby/blob/master/LICENSE.txt

describe Cube::Client do
  before do
    @cube = Cube::Client.new "cube.example.org", 1185
    class << @cube
      attr_reader :host, :port
      def socket ; @socket ||= FakeUDPSocket.new ; end
    end
  end

  after { @cube.socket.clear }

  describe "#initialize" do
    it "should set the host and port" do
      @cube.host.must_equal "cube.example.org"
      @cube.port.must_equal 1185
    end

    it "should default the host and port to localhost:1180" do
      cube = Cube::Client.new
      cube.instance_variable_get('@host').must_equal 'localhost'
      cube.instance_variable_get('@port').must_equal 1180
    end
  end

  describe "#send" do
    it "should format the message according to the Cube spec" do
      type = "request"
      time = DateTime.now
      data = { duration_ms: 234 }
      @cube.send type, time, data
      recv = JSON.parse @cube.socket.recv.first
      recv["type"].must_equal "request"
      recv["time"].must_equal time.iso8601
      recv["data"].must_equal({ "duration_ms" => 234 })
    end

    describe "with an id" do
      it "should format the message according to the Cube spec" do
        type = "request"
        time = DateTime.now
        id = 42
        data = { duration_ms: 234 }
        @cube.send type, time, id, data
        recv = JSON.parse @cube.socket.recv.first
        recv["type"].must_equal "request"
        recv["time"].must_equal time.iso8601
        recv["id"].must_equal 42
        recv["data"].must_equal({ "duration_ms" => 234 })
      end
    end
  end

  describe "with namespace" do
    before { @cube.namespace = 'someservice' }

    it "should add namespace to send" do
      @cube.send "request"
      recv = JSON.parse @cube.socket.recv.first
      recv["type"].must_equal 'someservice_request'
    end
  end

  describe "with logging" do
    require 'stringio'
    before { Cube::Client.logger = Logger.new(@log = StringIO.new) }

    it "should write to the log in debug" do
      Cube::Client.logger.level = Logger::DEBUG

      @cube.send "request"

      recv = @cube.socket.recv.first
      @log.string.must_match "Cube: #{recv}"
    end

    it "should not write to the log unless debug" do
      Cube::Client.logger.level = Logger::INFO

      @cube.send "request"

      recv = @cube.socket.recv.first
      @log.string.must_be_empty
    end
  end
end

describe Cube::Client do
  describe "with a real UDP socket" do
    it "should actually send stuff over the socket" do
      socket = UDPSocket.new
      host, port = 'localhost', 12345
      socket.bind host, port

      time = DateTime.now
      cube = Cube::Client.new host, port
      cube.send "request", time

      recv = JSON.parse socket.recvfrom(64).first
      recv["type"].must_equal "request"
      recv["time"].must_equal time.iso8601
    end
  end
end if ENV['LIVE']

