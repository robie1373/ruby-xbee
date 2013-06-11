require_relative "../../spec_helper"
require_relative "../../../lib/apimode/xbee_api"
require_relative "../../../lib/rf_module"
require_relative "../../../lib/apimode/frame/frame"
require_relative "../../../lib/apimode/frame/at_command_response"

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
        # "Check to make sure your firmware version is in the expectation array if this fails. Brittle test."
        ["21A7", "23A7"].should include @base_api_mode_interface.fw_rev.upcase
      end
    end

    describe "#get_param" do
      it "should yield a Frame to a block" do
        at_param_name = "VR"
        @base_api_mode_interface.get_param(at_param_name) do | response |
          response.should be_a_kind_of Frame::ATCommandResponse
        end
      end

      it "should have the param name in the response" do
        at_param_name = "BD"
        @base_api_mode_interface.get_param(at_param_name) do | response |
          response.at_command.upcase.should == at_param_name
        end
      end
    end

    describe "#neighbors" do
      it 'should return an array of neighbors' do
        pending "decide if you want to work on this yet"
        at_param_name = "ND"
        @base_api_mode_interface.get_param(at_param_name) do | response |
          response.at_command.upcase.should == ['foo']
        end
      end
    end

  end

end