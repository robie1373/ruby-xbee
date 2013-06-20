require_relative "../spec_helper"
require_relative '../../bin/apicontrol'
require_relative "../../bin/ruby-xbee"

describe "API binstub" do
  describe ApiMode do
    before :each do
      @input = StringIO.new("1\n")
      @output = StringIO.new
      @serial_config = SerialConfig.new(@input, @output)
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

    it "should set the remote radio D0 output low" do
      pending "Not sure I want to write a test to actually set voltage on remote radios. Find another end to end test to use I think."
      apimode = ApiMode.new(@serial_config, @input, @output)
      apimode.show_nd
      p apimode.result.nd.first
      remote_address = "0x#{apimode.result.nd.first[:SH]}#{apimode.result.nd.first[:SH]}"
      apimode.remote_d0_low(remote_address)
      true.should == false
    end

    describe "end to end message test" do
      before :each do
        @input1 = StringIO.new("1\n")
        @output1 = StringIO.new
        @input2 = StringIO.new("2\n")
        @output2 = StringIO.new
        @message = "Hello XBee"

        @radio1_apimode = ApiMode.new(@serial_config, @input1, @output1)
        @radio2_apimode = ApiMode.new(@serial_config, @input2, @output2)

        dest_address = @radio1_apimode.show_sn
        @radio1_apimode.transmit_req(dest_address, @message)
        @received_message = @radio2_apimode.receive_packet
      end

      it "should send a string from radio one to radio two" do
        received_message[:message].should == @message
      end

      it "should know the message came from radio 1" do
        received_message[:source_addr].should == @radio1_apimode.adress64
      end
    end

  end
end

