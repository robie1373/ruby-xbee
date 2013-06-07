require_relative '../spec_helper'
require_relative '../../lib/rf_module'

module XBee
  describe "rf_module" do
    describe "XBee::get_xbee_usbdev_str" do
      include XBee

      before(:each) do
        @devices = ["/dev/cu.usbserial-A9014A2H", "/dev/cu.usbserial-FTF4BHT6"]
        @input = StringIO.new
        @output = StringIO.new
      end

      it "should return a valid usb serial device for my environment" do
        @input << "1\n"
        @input.rewind
        get_xbee_usbdev_str(@input, @output).should =~ /\/dev\/cu\.usbserial-......../
      end
    end

    describe "XBee::ask_user_for_input" do
      include XBee

      before(:each) do
        @devices = ["/dev/cu.usbserial-A9014A2H", "/dev/cu.usbserial-FTF4BHT6"]
        @input = StringIO.new
        @output = StringIO.new
      end

      it "should show me the devices it found" do

        @input << "1\n1\n"
        @input.rewind

        self.ask_user_for_input(@devices, @input, @output)
        @output.string.should == "1. /dev/cu.usbserial-A9014A2H\n2. /dev/cu.usbserial-FTF4BHT6\nMultiple USB Serial devices found. Which would you like to use?\n"
      end

      it "should return just the string of the device the user chooses" do
        @input << "1\n1\n"
        @input.rewind
        self.ask_user_for_input(@devices, @input, @output).should == "/dev/cu.usbserial-A9014A2H"
      end
    end
  end

  describe RFModule do
    include XBee

    before(:each) do
      @input = StringIO.new
      @output = StringIO.new
      @input << "1\n"
      @input.rewind
      @rfmodule = RFModule.new(get_xbee_usbdev_str(@input, @output))
    end

    it "should initialize correctly" do
      @rfmodule.should be_a_kind_of RFModule
    end

    it "should have good attributes?" do
      @rfmodule.xbee_serialport.should be_a_kind_of SerialPort
    end
  end
end
