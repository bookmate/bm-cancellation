# frozen_string_literal: true

module BM
  class Cancellation
    # A cancellation object that expires after certain period of time.
    #
    # @example
    #   timeout = BM::Cancellation.timeout('MyWork', seconds: seconds)
    #   do_work until timeout.expired?
    #
    # @example joins with another cancellation
    #   cancellation.with_timeout('MyWork', seconds: 5).then do |timeout|
    #     do_work until timeout.expired?
    #   end
    #
    # @attr [String] name of the cancellation
    class Deadline < Cancellation
      attr_reader :name

      # @param name [String]
      # @param seconds_from_now [Numeric]
      # @param clock [#time]
      #
      # @api private
      def initialize(name:, seconds_from_now:, clock: Clock)
        super()
        @name = name.freeze
        @after = clock.time + seconds_from_now.to_f
        @seconds_from_now = seconds_from_now.to_f
        @clock = clock
      end

      # Is the current deadline expired
      #
      # @return [Boolean]
      def cancelled?
        @after < @clock.time
      end
      alias expired? cancelled?

      # Checks that the current deadline is expired
      #
      # @raise [DeadlineExpired] when the current deadline is expired
      # @return [nil]
      def check!
        return unless cancelled?

        raise DeadlineExpired, "Deadline [#{@name}] expired after #{@seconds_from_now.round(2)}s"
      end

      # Returns a number of remaining seconds for this deadline, if the deadline is
      # expired return a 0.
      #
      # @return [Float]
      def expires_after
        [(@after - @clock.time), 0].max
      end

      # A time source
      class Clock
        # Returns a monotonic time
        #
        # @return [Float]
        def self.time
          ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        end
      end
    end
  end
end
