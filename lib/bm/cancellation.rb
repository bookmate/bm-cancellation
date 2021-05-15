# frozen_string_literal: true

require 'bm/cancellation/version'
require 'bm/cancellation/atomic_bool'

module BM
  # Provides tools for cooperative cancellation
  class Cancellation
    ExecutionCancelled = Class.new(RuntimeError)
    DeadlineExpired = Class.new(ExecutionCancelled)

    ONE_YEAR = (365 * 24 * 3_600).to_f

    # @return [SignalControl]
    def self.signal(name)
      control = Control.new
      cancellation = Signal.new(name: name, control: control)
      SignalControl.new(cancellation: cancellation, control: control)
    end

    # @param name [String]
    # @param seconds_from_now [Float]
    # @return [Cancellation]
    def self.deadline(name, seconds_from_now:)
      Deadline.new(name: name, seconds_from_now: seconds_from_now)
    end

    # @param name [String]
    # @param seconds_from_now [Numeric]
    # @return [Cancellation]
    def with_deadline(name, seconds_from_now:)
      self | Deadline.new(name: name, seconds_from_now: seconds_from_now)
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

    # @api private
    class OrElse < Cancellation
      # @param left [Cancellation]
      # @param right [Cancellation]
      def initialize(left, right)
        super()
        @left = left
        @right = right
        @name = "#{left.name} | #{right.name}"
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

      # @return [String]
      def name
        return @left.name if @left.cancelled?
        return @right.name if @right.cancelled?

        @name
      end
    end

    # @attr [String] name
    # @api private
    class Deadline < Cancellation
      attr_reader :name

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

require 'bm/cancellation/signal'
