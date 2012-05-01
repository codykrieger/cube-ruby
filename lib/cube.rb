require 'cube/version'

module Cube
  require 'date'
  # We'll be sending data to Cube over a UDP socket.
  require 'socket'
  # Cube requires data to be in JSON format.
  require 'json'

  class Client
    # A namespace to prepend to all Cube calls.
    attr_accessor :namespace

    # We'll use this to eliminate any unwanted/disallowed characters from our
    # event type later on.
    RESERVED_CHARS_REGEX = /[^\w\d]/

    class << self
      # Set to any logger instance that responds to #debug and #error (like the
      # Rails or stdlib logger) to enable metric logging.
      attr_accessor :logger
    end

    # Set 'er up with a host and port, defaults to `localhost:1180`.
    #
    # @param [String] The hostname to send metrics to.
    # @param [Integer] The UDP port to send metrics to.
    def initialize(host="localhost", port=1180)
      @host, @port = host, port
    end

    # The primary endpoint for sending metrics to Cube.
    #
    # @param [String] The desired name of the new Cube event.
    # @param [Array] A splat that takes an optional DateTime, an event id
    #   (typically an integer, but can be any object), and a Hash of data.
    def send(type, *args)
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

      # Send off our parsed arguments to be further massaged and socketized.
      actual_send type, time, id, data
    end

    private

    # Actually send the given data to a socket, and potentially log it along
    # the way.
    #
    # @param [String] The desired name of the new Cube event.
    # @param [DateTime] Optional. A specific time when the Cube event occurred.
    # @param [Object] Optional. Typically an integer, but can be any object.
    # @param [Hash] Optional. Anything in this hash will be stored in the
    #   `data` subdocument of the Cube event.
    def actual_send(type, time, id, data)
      # Namespace support!
      prefix = "#{@namespace}_" unless @namespace.nil?
      # Get rid of any unwanted characters, and replace each of them with an _.
      type = type.to_s.gsub RESERVED_CHARS_REGEX, '_'

      # Start constructing the message to be sent to Cube over UDP.
      message = {
        type: "#{prefix}#{type}"
      }
      message[:time] = time.iso8601 unless time.nil?
      message[:id] = id unless id.nil?
      message[:data] = data unless data.nil?

      # JSONify it, log it, and send it off.
      message_str = message.to_json
      self.class.logger.debug { "Cube: #{message_str}" } if self.class.logger

      socket.send message_str, 0, @host, @port
    rescue => err
      self.class.logger.error { "Cube: #{err.class} #{err}" } if self.class.logger
    end

    # Helper for getting the socket. `@socket` can be set to a mock object to
    # test without needing an actual UDP socket.
    def socket ; @socket ||= UDPSocket.new ; end
  end
end
