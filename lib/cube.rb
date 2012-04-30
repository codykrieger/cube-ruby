require 'cube/version'

module Cube
  require 'date'
  require 'socket'
  require 'json'

  class Client
    # A namespace to prepend to all Cube calls
    attr_accessor :namespace

    RESERVED_CHARS_REGEX = /[^\w\d]/

    class << self
      # set to any logger instance that responds to #debug and #error (like the
      # rails or stdlib logger) to enable stat logging
      attr_accessor :logger
    end

    def initialize(host="localhost", port=1180)
      @host, @port = host, port
    end

    def send(type, *args)
      default_time = DateTime.now
      time = nil
      id = nil
      data = nil

      until args.empty?
        arg = args.shift
        if arg.is_a? DateTime
          time ||= arg
        elsif arg.is_a? Hash
          data ||= arg
        else
          id ||= arg
        end
      end

      actual_send type, (time || default_time), id, data
    end

    private

    def actual_send(type, time, id, data)
      prefix = "#{@namespace}_" unless @namespace.nil?
      type = type.to_s.gsub RESERVED_CHARS_REGEX, '_'
      message = {
        type: "#{prefix}#{type}",
        time: time.iso8601
      }
      message[:id] = id unless id.nil?
      message[:data] = data unless data.nil?

      message_str = message.to_json
      self.class.logger.debug { "Cube: #{message_str}" } if self.class.logger

      socket.send message_str, 0, @host, @port
    rescue => err
      self.class.logger.error { "Cube: #{err.class} #{err}" } if self.class.logger
    end

    def socket ; @socket ||= UDPSocket.new ; end
  end
end
