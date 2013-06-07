require_relative "../../spec_helper"
require_relative "../../../lib/legacy/command_mode"
require_relative "../../../bin/ruby-xbee"

module XBee
  describe BaseCommandModeInterface do
    before(:each) do
      @serial_config = SerialConfig.new
      @base_command_mode_interface = BaseCommandModeInterface.new(@serial_config.xbee_usbdev_str,
                                                                  @serial_config.xbee_baud,
                                                                  @serial_config.data_bits,
                                                                  @serial_config.stop_bits,
                                                                  @serial_config.parity)
    end

    def send_at_command(command_mode_interface, command)
      serial_port = command_mode_interface.xbee_serial_port
      serial_port.write("+++")
      sleep 1
      command_mode_interface.getresponse
      serial_port.write("#{command}\r")
      output = command_mode_interface.getresponse
      serial_port.write("ATCN\r")
      output
    end

    describe "Make sure you have a transparent mode xbee to work with. If this fails you probably don't." do
      it "should probe for an xbee in transparent" do
        @base_command_mode_interface.attention.should == "OK"
      end
    end

    it "should probe the firmware version" do
      pending "come back to this once you have API mode working"
      my_answer = send_at_command(@base_command_mode_interface, "ATVR")
      #sleep 1
      #@base_command_mode_interface.getresponse
      @base_command_mode_interface.fw_rev.should == my_answer
    end

    it "should probe the hardware version" do
      pending "come back to this once you have API mode working"
      my_answer = send_at_command(@base_command_mode_interface, "ATHV")
      @base_command_mode_interface.hw_rev.should == my_answer
    end
  end


end