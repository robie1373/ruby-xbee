require_relative "../../spec_helper"
require_relative "../../../lib/legacy/command_mode"

module XBee
  describe BaseCommandModeInterface do
    describe "I bet this is meant to be used with an xbee in transparent mode, not in API mode" do
      it "should remind me to try an xbee in transparent" do
        true.should == false
      end
    end
  end


end