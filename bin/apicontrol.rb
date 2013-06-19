#!/usr/bin/env ruby
$: << File.dirname(__FILE__)

require 'date'
require 'ruby-xbee'
require 'pp'

class ApiMode
  def initialize(serial_config, input = STDIN, output = STDOUT)
    @output = output
    @input = input
    @result = Result.new
    @xbee = XBee::BaseAPIModeInterface.new(serial_config.xbee_usbdev_str, @input, @output)
  end
  Result = Struct.new(:fw, :hw, :sh, :sl, :sn, :nd)

  def output
    @output
  end

  def show_fw
    @result.fw ||=  @xbee.fw_rev
    @output.puts @result.fw
  end

  def show_hw
    @result.hw ||= @xbee.hw_rev
    @output.puts @result.hw
  end

  def show_sh
    @result.sh ||= @xbee.serial_num_high
    @output.puts @result.sh
  end

  def show_sl
    @result.sl ||= @xbee.serial_num_low
    @output.puts @result.sl
  end

  def show_sn
    @result.sn ||= @xbee.serial_num
    @output.puts @result.sn
  end

  def show_nd
    @result.nd ||= @xbee.neighbors
    @output.puts @result.nd
  end

  def result
    @result
  end

  def remote_d0_low(remote_address)
    @xbee.set_remote_param("D0", 0x04, remote_address, 0xfffe, "C") { |r| r.inspect }
  end

  def run
    @output.puts "Testing API now ..."
    #output.puts "XBee Version: #{@xbee.version_long}"
    result.fw = @xbee.fw_rev
    @output.puts "Firmware Rev: #{@xbee.fw_rev}"
    @output.puts "Hardware Rev: #{@xbee.hw_rev}"
    @output.puts "Serial Number High: #{@xbee.serial_num_high}"
    @output.puts "Serial Number Low: #{@xbee.serial_num_low}"
    @output.puts "Serial Number: #{@xbee.serial_num}"
    tmp = @xbee.xbee_serialport.read_timeout
    @xbee.xbee_serialport.read_timeout = 5000
    @output.puts "Remote d0 = digital output low ... #{@xbee.set_remote_param("D0", 0x04, 0x0013a200404b229d, 0xfffe, "C") { |r| r.inspect } }"
    @output.puts "Remote d0 = digital output high ... #{@xbee.set_remote_param("D0", 0x05, 0x0013a200404b229d, 0xfffe, "C") { |r| r.inspect } }"
    sleep 5
    @xbee.xbee_serialport.read_timeout = tmp
    @output.puts "Detecting neighbors ..."
    response = @xbee.neighbors
    response.each do |r|
      @output.puts "----------------------"
      r.each do |key, val|
        @output.puts case key
                       when :NI
                         "#{key} = '#{val}'"
                       when :STATUS, :DEVICE_TYPE
                         "#{key} = 0x%02x" % val
                       when :SH, :SL
                         "#{key} = 0x%08x" % val
                       else
                         "#{key} = 0x%04x" % val
                     end
      end
    end
  end
end

apimode = ApiMode.new(@serial_config)

unless MODE == :test
  apimode.run
end