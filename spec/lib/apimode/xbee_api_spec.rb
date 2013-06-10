require_relative "../../spec_helper"
require_relative "../../../lib/apimode/xbee_api"
require_relative "../../../lib/rf_module"
require_relative "../../../lib/apimode/frame/frame"

module XBee
  describe BaseAPIModeInterface do
    include XBee
    before(:all) do
      xbee_usbdev_str = get_xbee_usbdev_str
      @base_api_mode_interface = BaseAPIModeInterface.new(xbee_usbdev_str)
    end

    before(:each) do
      @output = StringIO.new
    end

    describe "#fw_rev" do
      it "should get the firmware version" do
        pending "fix up get_param first"
        @base_api_mode_interface.fw_rev.should == "foo"
      end
    end

    describe "#get_param" do
      it "should yield a Frame to a block" do
        at_param_name = "FW"
        @base_api_mode_interface.get_param(at_param_name) do | response |
          response.should be_a_kind_of Frame
        end
      end
    end

  end

end