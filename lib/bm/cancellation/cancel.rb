# frozen_string_literal: true

module BM
  class Cancellation
    # Signals a cancel event to associated cancellation
    #
    # @example Usage
    #   cancellation, control = BM::Cancellation.cancel('MyWork')
    #   Signal.trap('INT') { control.done }
    #
    #   do_work until cancellation.cancelled?
    class Control
      # @api private
      def initialize
        @atomic = AtomicBool.new(false)
      end

      # Destructing to an array
      #
      # @return [(Control, AtomicBool)]
      # @api private
      def to_ary
        [self, @atomic]
      end

      # Finishes and fire a cancel event to associated cancellation. Safe to call multiple times from
      # multiple threads.
      #
      # @return [Boolean] true when invoked the 1st time
      def done
        @atomic.swap(false, true)
      end
    end

    # A cancellation object backed by atomic boolean. Becomes cancelled when an associated {Control}
    # has done.
    #
    # @example Usage
    #   cancellation, control = BM::Cancellation.cancel('MyWork')
    #   Signal.trap('INT') { control.done }
    #
    #   do_work until cancellation.cancelled?
    #
    # @attr [String] name of the cancellation
    class Cancel < Cancellation
      attr_reader :name

      # @param name [String]
      # @param atomic [AtomicBool]
      #
      # @api private
      def initialize(name:, atomic:)
        super()
        @name = name.freeze
        @atomic = atomic
      end

      # Is the cancellation cancelled
      #
      # @return [Boolean]
      def cancelled?
        @atomic.fetch
      end

      # Checks that the current cancellation is cancelled
      #
      # @raise [ExecutionCancelled] raises when the cancellation cancelled
      # @return [nil]
      def check!
        return unless cancelled?

        raise ExecutionCancelled, "Execution [#{name}] cancelled"
      end
    end
  end
end
