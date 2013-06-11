$: << File.dirname(__FILE__)

class String
  def xb_escape
    self.gsub(/[\176\175\021\023]/) { |c| [0x7D, c[0].ord ^ 0x20].pack("CC")}
  end
  def xb_unescape
    self.gsub(/\175./) { |ec| [ec.unpack("CC").last ^ 0x20].pack("C")}
  end
end

module XBee
  module Frame
    def Frame.checksum(data)
      #0xFF - (data.unpack("C*").inject(0) { |sum, byte| (sum + byte) & 0xFF })
      0xFF - (data.inject(0) { |sum, byte| (sum + byte) & 0xFF })
    end

    def Frame.new(source_io, input = STDIN, output = STDOUT)
      data = source_io.read
      #stray_bytes = stray_bytes(source_io)
      stray_bytes, clean_data = stray_bytes(data)
      output.puts "Got some stray bytes for ya: #{stray_bytes.map {|b| "0x%x" % b}.join(", ")}" unless stray_bytes.empty?

      #header = get_header(source_io)
      header = get_header(clean_data)

      frame_remaining = frame_length = api_identifier = ""
      #frame_length = get_length(header, source_io)
      frame_length = header[1] + header[2]
      #api_identifier = get_api_identifier(source_io)
      api_identifier = clean_data[3]

      #cmd_data = get_cmd_data(frame_length, source_io)


      #data = api_identifier.chr + cmd_data.xb_unescape
      data = clean_data[3..-2]

      #sent_checksum = source_io.getc
      sent_checksum = clean_data[-1]
      #puts "sent_checksum is #{sent_checksum}"
      #puts "computed checksum is #{Frame.checksum(clean_data[3..-2])}"
      #puts "clean_data is #{clean_data}"

      #puts "clean_data[3..-2] is #{clean_data[3..-2]}"
      unless sent_checksum == Frame.checksum(clean_data[3..-2])
        raise "Bad checksum - data discarded"
      end

      case data[0]
        when 0x8A
          ModemStatus.new(data)
        when 0x88
          ATCommandResponse.new(data)
        when 0x97
          RemoteCommandResponse.new(data)
        when 0x8B
          TransmitStatus.new(data)
        when 0x90
          ReceivePacket.new(data)
        when 0x91
          ExplicitRxIndicator.new(data)
      else ReceivedFrame.new(data)
      end
      #clean_data
    end

    #def self.get_cmd_data(frame_length, source_io)
    #  cmd_data_intended_length = frame_length - 1 #I think the -1 was wrong
    #  cmd_data = ""
    #  #source_io.seek(3)
    #  #puts "source_io length is #{source_io.read.length}"
    #  while ((unescaped_length = cmd_data.xb_unescape.length) < cmd_data_intended_length)
    #    next_chunk = source_io.read(cmd_data_intended_length - unescaped_length)
    #    cmd_data += next_chunk
    #  end
    #  cmd_data
    #end
    #
    #def self.get_api_identifier(data)
    #  data[3]
    #end
    #
    #def self.get_length(header, source_io)
    #  header.delete!("~")
    #  if header.length == 3
    #    frame_length, delimiter = header.unpack("nC")
    #  else
    #    frame_length, delimiter = header.unpack("n").first, source_io.readchar
    #  end
    #  return frame_length
    #end

    def self.get_header(frame, input = STDIN, output = STDOUT)
      #header = source_io.read(3).xb_unescape
      header = frame[0..2]
      #output.puts "Read header: #{header.join(", ")}"
      header
    end

    def self.stray_bytes(data, input = STDIN, output = STDOUT)
      #stray_bytes = []
      data_array = []
      data.each_byte { |b| data_array << b }
      stray_bytes = data_array.slice!(0...data_array.index(0x7e))
      length = data_array[1] + data_array[2]
      data_array.slice!((length + 4)..-1)
      #until (start_delimiter = source_io.readchar.ord) == 0x7e
      #  output.puts "Stray byte 0x%x" % start_delimiter.ord
      #  stray_bytes << start_delimiter
      #end
      return stray_bytes, data_array
    end

    class Base

      attr_accessor :api_identifier, :cmd_data, :frame_id

      def api_identifier ; @api_identifier ||= 0x00 ; end

      def cmd_data ; @cmd_data ||= "" ; end

      def length ; data.length ; end

      def data
        Array(api_identifier).pack("C") + cmd_data
      end

      def _dump
        raise "Too much data (#{self.length} bytes) to fit into one frame!" if (self.length > 0xFFFF)
        data_array = []
        data.each_byte { |b| data_array << b }
        "~" + [length].pack("n").xb_escape + data.xb_escape + [Frame.checksum(data_array)].pack("C")
      end

      def checksum(data)
        Frame::checksum data
      end
    end

    class ReceivedFrame < Base
      def initialize(frame_data)
        raise "Frame data must be an enumerable type" unless frame_data.kind_of?(Enumerable)
        self.api_identifier = frame_data[0]
        # puts "Initializing a ReceivedFrame of type 0x%x" % self.api_identifier
        self.cmd_data = frame_data
      end

      def checksum(data = self.cmd_data)
        super
      end
    end
  end
end

require 'at_command'
require 'at_command_response'
require 'explicit_addressing_command'
require 'explicit_rx_indicator'
require 'modem_status'
require 'receive_packet'
require 'remote_command_request'
require 'remote_command_response'
require 'transmit_request'
require 'transmit_status'

