# frozen_string_literal: true

require 'bm/cancellation/version'
require 'bm/cancellation/atomic_bool'

module BM
  # Provides tools for cooperative cancellation
  class Cancellation
    ExecutionCancelled = Class.new(RuntimeError)
    DeadlineExpired = Class.new(ExecutionCancelled)

    # The number of seconds in the one year
    EXPIRES_AFTER_MAX = (365 * 24 * 3_600).to_f

    class << self
      # @return [(Cancellation, Control)]
      def cancel(name)
        control, atomic = Control.new
        cancellation = Cancel.new(name: name, atomic: atomic)
        [cancellation, control].map(&:freeze)
      end

      # @param name [String]
      # @param seconds [Numeric]
      # @param clock [#time] override a time source (non public)
      # @return [Cancellation]
      def timeout(name, seconds:, clock: Deadline::Clock)
        Deadline.new(name: name, seconds_from_now: seconds, clock: clock).freeze
      end
    end

    # @param name [String]
    # @param seconds [Numeric]
    # @return [Cancellation]
    def with_timeout(name, seconds:)
      self | self.class.timeout(name, seconds: seconds)
    end

    # @return [Boolean]
    def cancelled?
      raise ArgumentError, 'not implemented'
    end

    # @raise [ExecutionCancelled]
    # @return [nil]
    def check!
      raise ArgumentError, 'not implemented'
    end

    # @return [Float]
    def expires_after
      EXPIRES_AFTER_MAX
    end

    # @param other [Cancellation]
    # @return [Cancellation]
    def or_else(other)
      Either.new(left: self, right: other).freeze
    end
    alias | or_else
  end
end

require 'bm/cancellation/cancel'
require 'bm/cancellation/deadline'
require 'bm/cancellation/either'
