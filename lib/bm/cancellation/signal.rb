# frozen_string_literal: true

module BM
  class Cancellation
    # @!attribute [r] cancellation
    #   @return [Cancellation]
    # @!attribute [r] control
    #   @return [Control]
    class SignalControl
      attr_reader :cancellation, :control

      # @param cancellation [Cancellation]
      # @param control [Control]
      def initialize(cancellation:, control:)
        @cancellation = cancellation
        @control = control
      end

      # @return [(Cancellation, Control)]
      def to_ary
        [cancellation, control]
      end
    end

    # @!attribute [r] atomic
    #   @return [AtomicBool]
    #   @api private
    class Control
      attr_reader :atomic

      # Creates a new instance
      #
      # @api private
      def initialize
        @atomic = AtomicBool.new(false)
      end

      # @return [Boolean]
      def cancel
        atomic.swap(false, true)
      end

      # @return [Boolean]
      def cancelled?
        atomic.fetch
      end
    end

    # @!attribute [r] name
    #   @return [String]
    class Signal < Cancellation
      attr_reader :name

      # @param name [String]
      # @param control [Control]
      #
      # @api private
      def initialize(name:, control:)
        super()
        @name = name
        @atomic = control.atomic
      end

      # @return [Boolean]
      def cancelled?
        @atomic.fetch
      end

      # @raise [ExecutionCancelled]
      # @return [nil]
      def check!
        return unless cancelled?

        raise ExecutionCancelled, "Execution [#{name}] cancelled"
      end
    end
  end
end
