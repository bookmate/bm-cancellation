# frozen_string_literal: true

module BM
  # Interface methods for cancellations
  #
  # @!attribute reason [r]
  #   Is an cancellation reason (by signal or by timeout) must be implemented on derived classes
  #   @return [String]
  #
  # @!method cancelled?
  #   Is the cancellation cancelled
  #   @return [Boolean]
  #
  # @!method check!
  #   Checks that the current cancellation is cancelled or not
  #
  #   @raise [ExecutionCancelled] when the cancellation is cancelled
  #   @return [nil]
  module Cancellation
    # Raised by {Cancellation#check!} when a cancellation is cancelled
    ExecutionCancelled = Class.new(RuntimeError)

    # Raised by #{Cancellation#check!} when a deadline cancellation is expired
    DeadlineExpired = Class.new(ExecutionCancelled)

    # The number of seconds in the one year
    EXPIRES_AFTER_MAX = (365 * 24 * 3_600).to_f

    # TLS key for storing and retrieving the current cancellation
    THREAD_KEY = 'BM::Cancellation'

    # Combines the cancellation with another that expired after given seconds.
    #
    # @example Usage with another cancellation
    #   cancellation.timeout(seconds: 5).then do |timeout|
    #     do_work until timeout.expired?
    #   end
    #
    # @param seconds [Numeric] is a number of seconds when timeout becomes expired
    #
    # @return [Cancellation]
    def timeout(seconds:)
      self | Cancellation.timeout(seconds: seconds)
    end

    # Creates a new cancellation that resolved by signal and joins it with the current
    # cancellation
    #
    # @return [Control]
    def new
      Control.new { self | _1 }.freeze
    end

    # Combines the cancellation with another using {Either}
    #
    # @param other [Cancellation]
    # @return [Cancellation]
    def or_else(other)
      Either.new(left: self, right: other).freeze
    end
    alias | or_else

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

    # Stores the current cancellation in the current thread, invokes a given block and
    # then cleanup the current cancellation from the thread
    #
    # @see BM::Cancellation.current
    def using
      return unless block_given?

      before = Thread.current[THREAD_KEY]
      begin
        Thread.current[THREAD_KEY] = self
        yield
      ensure
        Thread.current[THREAD_KEY] = before
      end
    end

    # Returns the current cancellation that before stored in the current thread
    #
    # @return [BM::Cancellation]
    # @raise [ArgumentError] when no cancellation found at thread locals
    #
    # @see BM::Cancellation#using
    def self.current
      Thread.current[THREAD_KEY] || raise(ArgumentError, 'No cancellation found in the current thread')
    end

    # Checks that a cancellation is exist in the thread locals
    # @return [Boolean]
    def self.current?
      !!Thread.current[THREAD_KEY]
    end
  end
end
