require 'highline/import'
module XBee

  def platform_dev_string
  platform = RUBY_PLATFORM.downcase
    case
    when platform =~ /darwin/
      "/dev/cu\.usbserial*"
    when platform =~ /linux/
      "/dev/ttyUSB*"
    else
      raise "unknown or unsupported platform."
    end
  end

  def ask_user_for_input(list_array, input = STDIN, output = STDOUT)
    terminal = HighLine.new(input, output)
    answer = terminal.choose do |menu|
      menu.prompt = "Multiple USB Serial devices found. Which would you like to use?"
      list_array.each { |dev| menu.choice dev.to_sym do dev end }
    end
    answer
  end

  def get_xbee_usbdev_str(input = STDIN, output = STDOUT)
    begin
      unless input.tty?
        unless input.is_a? StringIO
          input = StringIO.new
          input << "1\n"
          input.rewind
        end
      end
      devices = Dir.glob(platform_dev_string)
      case devices.length
        when 0
          raise "No USB Serial devices found"
        when 1
          usb_serial_dev_str = devices.first
        else
          usb_serial_dev_str = ask_user_for_input(devices, input, output)
      end
    rescue => e
      output.puts "something unexpected happened while getting USB serial device name"
      raise e
    end
    usb_serial_dev_str
  end

  ##
  # This is it, the base class where it all starts. Command mode or API mode, version 1 or version 2, all XBees descend
  # from this class.
  class RFModule
    include XBee
    include Config
    attr_accessor :xbee_serialport, :xbee_uart_config, :guard_time, :command_mode_timeout, :command_character, :node_discover_timeout, :node_identifier
    attr_reader :serial_number, :hardware_rev, :firmware_rev


    def version
      "2.0"
    end

    ##
    # This is the way we instantiate XBee modules now, via this factory method. It will ultimately autodetect what
    # flavor of XBee module we're using and return the most appropriate subclass to control that module.
    def initialize(xbee_usbdev_str = get_xbee_usbdev_str, uart_config = XBeeUARTConfig.new)
      unless uart_config.kind_of?(XBeeUARTConfig)
        raise "uart_config must be an instance of XBeeUARTConfig for this to work"
      end
      self.xbee_uart_config = uart_config
      @xbee_serialport = SerialPort.new(xbee_usbdev_str, uart_config.baud, uart_config.data_bits, uart_config.stop_bits, uart_config.parity)
      @xbee_serialport.read_timeout = self.read_timeout(:short)
      @guard_time = GuardTime.new
      @command_mode_timeout= CommandModeTimeout.new
      @command_character = CommandCharacter.new
      @node_discover_timeout = NodeDiscoverTimeout.new
      @node_identifier = NodeIdentifier.new
    end

    def xbee_serialport
      @xbee_serialport
    end

    def in_command_mode
      sleep self.guard_time.in_seconds
      @xbee_serialport.write(self.command_character.value * 3)
      sleep self.guard_time.in_seconds
      @xbee_serialport.read(3)
      # actually do some work now ...
      yield if block_given?
      # Exit command mode
      @xbee_serialport.write("ATCN\r")
      @xbee_serialport.read(3)
    end

    ##
    # XBee response times vary based on both hardware and firmware versions. These
    # constants may need to be adjusted for your devices, but these will
    # work fine for most cases.  The unit of time for a timeout constant is ms
    def read_timeout(type = :short)
      case type
        when :short
          1200
        when :long
          3000
        else
          3000
      end
    end
  end
end
