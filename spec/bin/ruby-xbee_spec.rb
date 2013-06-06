require_relative "../spec_helper"
require_relative "../../bin/ruby-xbee"

describe "ruby-xbee binstub" do
  describe "serial port attributes" do
    before(:each) do
      @serial_config = SerialConfig.new
    end
    it "should read attributes" do
      @serial_config.xbee_baud.should == 9600
    end
  end
end