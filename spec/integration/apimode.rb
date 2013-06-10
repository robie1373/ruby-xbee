require_relative "../spec_helper"
require_relative "../../lib/apimode/xbee_api"
require_relative "../../lib/rf_module"
require_relative "../../lib/apimode/xbee_api"

describe "end to end test of apimode" do
  include XBee
  before(:all) do
      input = StringIO.new("1\n")
      output = StringIO.new
      @radio_1_dev_string = get_xbee_usbdev_str(input, output)
      input = StringIO.new("2\n")
      @radio_2_dev_string = get_xbee_usbdev_str(input, output)
  end
  describe "pass a message between 2 radios in apimode" do

    it "should have radio 1 available" do
      #input = StringIO.new("1\n")
      #output = StringIO.new
      #@radio_1_dev_string = get_xbee_usbdev_str(input, output)
      @radio_1_dev_string.should =~ /\/dev\/cu\.usbserial/
    end

    it "should have radio 2 available" do
      #input = StringIO.new("2\n")
      #output = StringIO.new
      #@radio_2_dev_string = get_xbee_usbdev_str(input, output)
      @radio_2_dev_string.should =~ /\/dev\/cu\.usbserial/
    end

    it "the two radio dev strings should not be the same" do
      @radio_1_dev_string.should_not ==  @radio_2_dev_string
    end
  end

  describe "create serial devices" do
    include XBee
    before(:all) do
      @dev1 = XBee::BaseAPIModeInterface.new(@radio_1_dev_string)
      @dev2 = XBee::BaseAPIModeInterface.new(@radio_2_dev_string)
    end
  
    describe "check the fw_ver to see if the device is working" do
      it "should show me the fw_rev of the first radio" do
        @dev1.fw_rev.should == "foo"
      end

      it "should show me the fw_rev of the first radio" do
        @dev1.fw_rev.should == "foo"
      end
    end 

  end

end