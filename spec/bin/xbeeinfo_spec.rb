require_relative "../spec_helper"
require_relative "../../bin/xbeeinfo"
require_relative "../../bin/ruby-xbee"

describe "xbeeinfo binstub" do
  describe XBeeInfo do
    before(:all) do
      serial_config = SerialConfig.new
      @output = StringIO.new
      #puts "xbeeinfo_spec before :each - #{serial_config.xbee_usbdev_str}"
      @xbeeinfo = XBeeInfo.new(serial_config, @output)
      @xbeeinfo.print
    end

    it "should print a firmware string" do
      @output.string.should =~ /Attention: OK/

    end
  end
end
