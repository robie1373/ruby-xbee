require_relative "../../../../spec/spec_helper"
require_relative "../../../../lib/apimode/frame/frame"
require_relative "../../../../lib/rf_module"

module XBee
  module Frame
    describe "module Frame" do
      before(:all) do
        @sample_frame_with_junk = [0x61, 0x62, 0x63, 0x31, 0x32, 0x33, 0x7e,
                                   0x00, 0x04, 0x08, 0x52, 0x4e, 0x4a, 0x0d].map { |i| i.chr }.join
        @sample_at_cmd_frame = [0x7e, 0x00, 0x04, 0x08, 0x52, 0x4e, 0x4a, 0x0d].map { |i| i.chr }.join
        @sample_at_response_frame = [0x7e, 0x00, 0x05, 0x88, 0x01, 0x42, 0x44, 0x00, 0xf0].map { |i| i.chr }.join
        @sample_zb_tx_req_frame = [0x7e, 0x00, 0x16, 0x10, 0x01, 0x00, 0x13, 0xa2, 0x00,
                                    0x40, 0x0a, 0x01, 0x27, 0xff, 0xfe, 0x00, 0x00, 0x54,
                                    0x78, 0x44, 0x61, 0x74, 0x61, 0x30, 0x41, 0x13].map { |i| i.chr }.join
        @sample_frames = [@sample_at_cmd_frame, @sample_at_response_frame]
      end

      before(:each) do
        @input = StringIO.new
        @output = StringIO.new
      end

      describe "Frame#checksum" do
        it "should compute the checksum" do
          data = "89ab"
          Frame.checksum(data).should == 0xCB
        end
      end

      describe "#stray_bytes" do
        it "should return an array of bytes up to 0x7e" do
          source_io = StringIO.new(@sample_frame_with_junk)
          Frame.stray_bytes(source_io, @input, @output).should == %w{ a b c 1 2 3 }.map { |i| i.ord }
        end
      end

      describe "#get_header" do
        it "should return a frame header" do
          @sample_frames.each do |frame|
            source_io = StringIO.new(frame)
            Frame.get_header(source_io, @input, @output).should == frame[0..2]
          end
        end

        it "should return a frame header from a real radio" do
          include XBee
          source_io = RFModule.new.xbee_serialport
          at_command_frame = XBee::Frame::ATCommand.new("VR",1,nil,"")
          source_io.read
          source_io.write at_command_frame._dump
          Frame.get_header(source_io, @input, @output).should == "~\x00\x07"
        end
      end

      describe "#get_length" do
        it "should return the length" do
          @sample_frames.each do |frame|
            source_io = StringIO.new(frame)
            header = frame[0..2]
            length = header[1].ord + header[2].ord
            frame_length = Frame.get_length(header, source_io)
            frame_length.should == length
          end
        end
      end

      describe "#get_api_identifier" do
        it "should return an api_identifier" do
          @sample_frames.each do |frame|
            source_io = StringIO.new(frame)
            Frame.get_api_identifier(source_io).should == frame[3]
          end
        end
      end

      describe "#get_cmd_data" do
        it "should return the command bytes from the frame" do
          @sample_frames.each do |frame|
            source_io = StringIO.new(frame)
            frame_length = frame[1].ord + frame[2].ord
            frame_data = frame[3..-2]
            Frame.get_cmd_data(frame_length, source_io).should == frame_data
          end
        end

        it "should get command data from a real radio" do
          include XBee
          source_io = RFModule.new.xbee_serialport
          at_command_frame = XBee::Frame::ATCommand.new("VR",1,nil,"")
          source_io.read
          source_io.write at_command_frame._dump
          frame = Frame.new(source_io, @input, @output)
          frame.should be_a_kind_of Frame
        end
      end

    end
  end
end
