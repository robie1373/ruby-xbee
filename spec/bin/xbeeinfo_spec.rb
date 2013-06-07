require_relative "../spec_helper"
require_relative "../../bin/xbeeinfo"
require_relative "../../bin/ruby-xbee"

describe "xbeeinfo binstub" do
  describe XBeeInfo do
    before(:all) do
      pending "Uncomment this line and change run_now to true to run these tests. They should be run separately due to speed and issues getting exclusive access to the radio."
      puts "This set of tests takes about 1 minute as it polls the radio and suffers timeouts etc.\nBe patient or run it separately."
      run_now = false
      if run_now
        serial_config = SerialConfig.new
        @output = StringIO.new
        #puts "xbeeinfo_spec before :each - #{serial_config.xbee_usbdev_str}"
        @xbeeinfo = XBeeInfo.new(serial_config, @output)
        @xbeeinfo.print
      end
    end

    it "should print respond to AT" do
      @output.string.should =~ /Attention: OK/
    end

    it "should print the firmware version" do
      @output.string.should =~ /Firmware: ..../
    end

    it "should print the hardware version" do
      @output.string.should =~ /Hardware: ..../
    end

    it "should print the Baud rate" do
      @output.string.should =~ /Baud: 9600/
    end

    it "should print the parity" do
      @output.string.should =~ /Parity: None/
    end

    it "should print it's PAN ID" do
      @output.string.should =~ /PAN ID:/
    end

    it "should print it's signal strength" do
      @output.string.should =~ /Last received signal strength \(dBm\):/
    end

    it "should print it's addressing info" do
      %w{Neighbors: Channel: MY: SH: SL: DH: DL:}.each do |item|
        @output.string.should =~ /#{item}/
      end
    end


  end
end
