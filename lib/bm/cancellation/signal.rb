# frozen_string_literal: true

require 'concurrent'

if RUBY_ENGINE == 'ruby' && !Concurrent.const_defined?(:CAtomicBoolean)
  warn '[PERFORMANCE] The gem "concurrent-ruby-ext" is strongly recommended to install' \
       ' to avoid performance penalty of BM::Cancellation'
end

module BM
  module Cancellation
    # Signals a cancel event to associated cancellation
    #
    # @example Usage
    #   cancellation, control = BM::Cancellation.new
    #   Signal.trap('INT', &control)
    #
    #   do_work until cancellation.cancelled?
    #
    # @!attribute cancellation [r]
    #   @return [BM::Cancellation]
    class Control
      attr_reader :cancellation

      # @api private
      def initialize
        @atomic = Concurrent::AtomicBoolean.new(false)
        @cancellation = Signal.new(@atomic)
        @cancellation = yield @cancellation if block_given?
        @cancellation.freeze
      end

      # Destructing to an array
      #
      # @return [(Cancellation, Control)]
      # @api private
      def to_ary
        [cancellation, self]
      end

      # Converts to proc
      #
      # @example Trap a signal
      #   Signal.trap('INT', &control)
      #
      # @return [Proc]
      def to_proc
        ->(*_args, **_kwargs) { done }
      end

      # Finishes and fire a cancel event to associated cancellation. Safe to call multiple times from
      # multiple threads.
      #
      # @return [Boolean] true when invoked the 1st time
      def done
        @atomic.make_true
      end
    end

    # A cancellation object backed by atomic boolean. Becomes cancelled when an associated {Control}
    # has done.
    #
    # @example Usage
    #   cancellation, control = BM::Cancellation.new
    #   Signal.trap('INT', &control)
    #
    #   do_work until cancellation.cancelled?
    class Signal
      include Cancellation

      # @param atomic [Concurrent::AtomicBoolean]
      #
      # @api private
      def initialize(atomic)
        @atomic = atomic
      end

      # Is the cancellation cancelled
      #
      # @return [Boolean]
      def cancelled?
        @atomic.true?
      end

      # Checks that the current cancellation is cancelled
      #
      # @raise [ExecutionCancelled] raises when the cancellation cancelled
      # @return [nil]
      def check!
        return unless cancelled?

        raise ExecutionCancelled, reason
      end

      # @return [String]
      def reason
        'Execution cancelled by signal'
      end
    end
  end
end
