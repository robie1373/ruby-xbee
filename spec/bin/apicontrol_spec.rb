require_relative "../spec_helper"
require_relative '../../bin/apicontrol'
require_relative "../../bin/ruby-xbee"

describe "API binstub" do
  describe ApiMode do
    before :each do
      @input = StringIO.new
      @output = StringIO.new
      @serial_config = SerialConfig.new
    end

    it "should display the firmware rev" do
      #pending "work on underpinnings"
      ApiMode.new(@serial_config, @input, @output).show_fw
      @output.string.should =~ /[0-9a-fA-F]{4}/
    end

    it "should display the hardware rev" do
      ApiMode.new(@serial_config, @input, @output).show_hw
      @output.string.should =~ /[0-9a-fA-F]{3,4}/
    end

    it "should display the serial number high" do
      ApiMode.new(@serial_config, @input, @output).show_sh
      @output.string.should =~ /[0-9a-fA-F]{3,4}/
    end

    it "should display the serial number low" do
      ApiMode.new(@serial_config, @input, @output).show_sl
      @output.string.should =~ /[0-9a-fA-F]{3,4}/
    end

    it "should display the whole serial number" do
      ApiMode.new(@serial_config, @input, @output).show_sn
      @output.string.should =~ /[0-9a-fA-F]{3,4}/
    end

    it "should display the neighbors" do
      apimode = ApiMode.new(@serial_config, @input, @output)
      apimode.show_nd
      apimode.result.nd.first.keys.should =~ [:DEVICE_TYPE,
                                              :MANUFACTURER_ID,
                                              :NI,
                                              :PARENT_NETWORK_ADDRESS,
                                              :PROFILE_ID,
                                              :SH,
                                              :SL,
                                              :STATUS]
    end
  end
end

