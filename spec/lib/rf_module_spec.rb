require_relative '../spec_helper'
require_relative '../../lib/rf_module'

module XBee
  describe "rf module" do
    describe "XBee::get_xbee_usbdev_str" do
      include XBee
      it "should return a valid usb serial device for my environment" do
        get_xbee_usbdev_str.should == "foo"
      end
    end

    describe "XBee::ask_user_for_input" do
      include XBee
      it "should show me the devices it found" do
        devices = ["/dev/cu.usbserial-A9014A2H", "/dev/cu.usbserial-FTF4BHT6"]
        input = StringIO.new
        output = StringIO.new
       self.ask_user_for_input(devices, input, output)
        output.string.should == "Multiple USB Serial devices found.\nWhich would you like to use?\n------------------------------------\n/dev/cu.usbserial-A9014A2H\n/dev/cu.usbserial-FTF4BHT6\n"
      end
end
  end
end
