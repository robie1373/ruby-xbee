#!/usr/bin/env ruby

begin
  require 'rubygems'
  gem 'ruby-xbee'
rescue LoadError => e
  load_path_addition = File.dirname(File.dirname(__FILE__)) + "/lib"
  puts "Falling back to extended load path #{load_path_addition}"
  $: << load_path_addition
  require 'ruby_xbee'
end

class SerialConfig
  include XBee
  def initialize
    @xbee_usbdev_str = get_xbee_usbdev_str
  end

  def xbee_usbdev_str
    @xbee_usbdev_str
  end

  def xbee_baud
    9600
  end

  def data_bits
    8
  end

  def stop_bits
    1
  end

  def parity
    0
  end
end

@serial_config = SerialConfig.new

#    case ARGV[0]
#                     when "cable"
#                       "/dev/tty.usbserial-FTE4UXEA"
#  else "/dev/tty.usbserial-A7004nmf"
#end

# default baud - this can be overridden on the command line
#@xbee_baud = 9600

# serial framing
#@data_bits = 8
#@stop_bits = 1
#@parity = 0

