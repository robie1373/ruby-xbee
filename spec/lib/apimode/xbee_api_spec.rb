require_relative "../../spec_helper"
require_relative "../../../lib/apimode/xbee_api"
require_relative "../../../lib/rf_module"
require_relative "../../../lib/apimode/frame/frame"

module XBee
  describe BaseAPIModeInterface do
    include XBee
    before(:each) do
      @output = StringIO.new
      xbee_usbdev_str = get_xbee_usbdev_str
      @base_api_mode_interface = BaseAPIModeInterface.new(xbee_usbdev_str)
    end

    describe "#fw_rev" do
      it "should get the firmware version" do
        pending "fix up Frame first"
        @base_api_mode_interface.fw_rev.should == "foo"
      end
    end

  end

end