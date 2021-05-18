# frozen_string_literal: true

module BM
  module Cancellation
    # A cancellation object that expires after certain period of time.
    #
    # @example Usage
    #   timeout = BM::Cancellation.timeout(seconds: seconds)
    #   do_work until timeout.expired?
    #
    # @example Joins with another cancellation
    #   cancellation.timeout(seconds: 5).then do |timeout|
    #     do_work until timeout.expired?
    #   end
    #
    # @attr [String] name of the cancellation
    class Deadline
      include Cancellation

      attr_reader :reason

      # @param seconds_from_now [Numeric]
      # @param clock [#time]
      #
      # @api private
      def initialize(seconds_from_now:, clock: Clock)
        @after = clock.time + seconds_from_now.to_f
        @seconds_from_now = seconds_from_now.to_f
        @clock = clock
        @reason = "Deadline expired after #{@seconds_from_now.round(2)}s"
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

        raise DeadlineExpired, reason
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
