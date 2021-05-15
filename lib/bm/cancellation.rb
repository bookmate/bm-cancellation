# frozen_string_literal: true

require 'concurrent'

module BM
  # Provides tools for cooperative cancellation
  class Cancellation
    ExecutionCancelled = Class.new(RuntimeError)
    DeadlineExpired = Class.new(ExecutionCancelled)

    ONE_YEAR = (365 * 24 * 3_600).to_f

    # @return [(OnceToken, Cancellation)]
    def self.once(name)
      token = OnceToken.new
      cancellation = Once.new(name: name, token: token)
      [token, cancellation]
    end

    # @param name [String]
    # @param seconds_from_now [Float]
    # @return [Cancellation]
    def self.deadline(name, seconds_from_now:)
      Deadline.new(name: name, seconds_from_now: seconds_from_now)
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
      ONE_YEAR
    end

    # @param other [Cancellation]
    # @return [Cancellation]
    def or_else(other)
      OrElse.new(self, other)
    end
    alias | or_else

    # @attr [Concurrent::AtomicBoolean] atomic
    #
    # @api private
    class OnceToken
      attr_reader :atomic

      # Creates a new instance
      def initialize
        @atomic = ::Concurrent::AtomicBoolean.new(false)
      end

      # @return [Boolean]
      def cancel
        @atomic.make_true
      end

      # @return [Boolean]
      def cancelled?
        @atomic.true?
      end
    end

    # @api private
    class Once < Cancellation
      # @param name [String]
      # @param token [OnceToken]
      def initialize(name:, token:)
        super()
        @name = name
        @atomic = token.atomic
      end

      # @return [Boolean]
      def cancelled?
        @signal.true?
      end

      # @raise [ExecutionCancelled]
      # @return [nil]
      def check!
        return unless cancelled?

        raise ExecutionCancelled, "Execution [#{@name}] cancelled"
      end
    end

    # @api private
    class OrElse < Cancellation
      # @param left [Cancellation]
      # @param right [Cancellation]
      def initialize(left, right)
        super()
        @left = left
        @right = right
      end

      # @return [Boolean]
      def cancelled?
        @left.cancelled? || @right.cancelled?
      end

      # @raise [ExecutionCancelled]
      # @return [nil]
      def check!
        @left.check! || @right.check!
      end

      # @return [Float]
      def expires_after
        [@left.expires_after, @right.expires_after].min
      end
    end

    # @api private
    class Deadline < Cancellation
      # @param name [String]
      # @param seconds_from_now [Float]
      def initialize(name:, seconds_from_now:)
        super()
        @name = name
        @after = clock_get_time + seconds_from_now
        @seconds_from_now = seconds_from_now
      end

      # @return [Boolean]
      #
      # @see Cancellation#cancelled?
      def cancelled?
        @after < clock_get_time
      end

      # @see Cancellation#check!
      def check!
        return unless cancelled?

        raise DeadlineExpired, "Deadline [#{@name}] expired after #{@seconds_from_now.round(2)}s"
      end

      # @return [Float]
      def expires_after
        [(@after - clock_get_time), 0].max
      end

      private

      # @return [Float]
      def clock_get_time
        ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
      end
    end
  end
end
