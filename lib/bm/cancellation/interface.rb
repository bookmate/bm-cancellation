# frozen_string_literal: true

module BM
  class Cancellation
    # Raised by {#check} when a cancellation is cancelled
    ExecutionCancelled = Class.new(RuntimeError)

    # Raised by #{check!} when a deadline cancellation is expired
    DeadlineExpired = Class.new(ExecutionCancelled)

    # The number of seconds in the one year
    EXPIRES_AFTER_MAX = (365 * 24 * 3_600).to_f

    # Combines the cancellation with a timeout
    #
    # @param name [String] is a timeout's name
    # @param seconds [Numeric] is a number of seconds when timeout becomes expired
    #
    # @return [Cancellation]
    def with_timeout(name, seconds:)
      self | self.class.timeout(name, seconds: seconds)
    end

    # Is the cancellation cancelled
    #
    # @return [Boolean] the current status: cancelled or not
    def cancelled?
      raise ArgumentError, 'not implemented'
    end

    # Checks that the current cancellation is cancelled
    #
    # @raise [ExecutionCancelled] when the cancellation is cancelled
    # @return [nil]
    def check!
      raise ArgumentError, 'not implemented'
    end

    # Returns a number of remaining seconds for this cancellation,
    #
    # Possible values:
    # - `0` if the cancellation is expired
    # - `MAX_TIME` if the cancellation is not depending on time sources
    #
    # @return [Float]
    def expires_after
      EXPIRES_AFTER_MAX
    end

    # Combines the cancellation with another using {Either}
    #
    # @param other [Cancellation]
    # @return [Cancellation]
    def or_else(other)
      Either.new(left: self, right: other).freeze
    end
    alias | or_else
  end
end
