# frozen_string_literal: true

module BM
  # Interface methods for cancellations
  module Cancellation
    # Raised by {Cancellation#check!} when a cancellation is cancelled
    ExecutionCancelled = Class.new(RuntimeError)

    # Raised by #{Cancellation#check!} when a deadline cancellation is expired
    DeadlineExpired = Class.new(ExecutionCancelled)

    # The number of seconds in the one year
    EXPIRES_AFTER_MAX = (365 * 24 * 3_600).to_f

    # Is the cancellation cancelled
    #
    # @return [Boolean]
    def cancelled?
      false
    end

    # Combines the cancellation with another that expired after given seconds.
    #
    # @example Usage with another cancellation
    #   cancellation.with_timeout('MyWork', seconds: 5).then do |timeout|
    #     do_work until timeout.expired?
    #   end
    #
    # @param name [String] is a timeout's name
    # @param seconds [Numeric] is a number of seconds when timeout becomes expired
    #
    # @return [Cancellation]
    def with_timeout(name, seconds:)
      self | Cancellation.timeout(name, seconds: seconds)
    end

    # Combines the cancellation with another using {Either}
    #
    # @param other [Cancellation]
    # @return [Cancellation]
    def or_else(other)
      Either.new(left: self, right: other).freeze
    end
    alias | or_else

    # Checks that the current cancellation is cancelled or not
    #
    # @raise [ExecutionCancelled] when the cancellation is cancelled
    # @return [nil]
    def check!
      nil
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
  end
end
