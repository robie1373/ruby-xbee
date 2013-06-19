require_relative "../spec_helper"
require_relative "../../bin/ruby-xbee"

describe "ruby-xbee binstub" do
  describe "serial port attributes" do
    before(:each) do
      input = StringIO.new("1\n")
      output = StringIO.new
      @serial_config = SerialConfig.new(input, output)
    end
    it "should read attributes" do
      @serial_config.xbee_baud.should == 9600
    end
  end
end