module XBee
  module Frame
    class ATCommandResponse < ReceivedFrame
      attr_accessor :frame_id, :at_command, :status, :retrieved_value

      def initialize(data = nil)
        super(data) && (yield self if block_given?)
      end

      def command_statuses
        [:OK, :ERROR, :Invalid_Command, :Invalid_Parameter, :TxFailure]
      end

      def cmd_data=(data_string)
        #puts "at_command_response#cmd_data data_string -> #{data_string}"
        #self.frame_id, self.at_command, status_byte, self.retrieved_value = data_string.unpack("Ca2Ca*")
        self.frame_id = data_string[1]
        self.at_command = data_string[2].chr + data_string[3].chr
        status_byte = data_string[4]
        if data_string.length > 5
          #puts "literal retrieved value -> #{p data_string[5..-1].map! { |i| i.to_s(16)}}"
          self.retrieved_value = data_string[5..-1].map! { |i| i.to_s(16) }.join
        end

        self.status = case status_byte
                        when 0..4
                          command_statuses[status_byte]
                        else
                          raise "AT Command Response frame appears to include an invalid status: 0x%x" % status_byte
                      end
        #actually assign and move along
        @cmd_data = data_string
      end
    end
  end
end
