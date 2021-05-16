# frozen_string_literal: true

module BM
  module Cancellation
    # A boolean value that can be updated atomically. Reads and writes to an atomic boolean
    # and thread-safe and guaranteed to succeed.
    #
    # Unlike {Concurrent::AtomicBoolean} that uses a mutex this class is backed by C11 atomics
    # that gives the 5X performance benefit.
    #
    # @api private
    #
    # @see https://en.cppreference.com/w/c/atomic
    #
    # @!method initialize(initial_value)
    #   Creates a new atomic which initial value
    #
    #   @param initial_value [Boolean]
    #   @api private
    #
    # @!method fetch
    #   Atomically loads and returns the current value using the `memory_order_acquire` semantic.
    #
    #   @see https://en.cppreference.com/w/c/atomic/atomic_load
    #
    #   @return [Boolean]
    #   @api private
    #
    # @!method swap(expected, desired)
    #   Atomically compares the contents of the current boolean using the `memory_order_seq_cst` semantic with the
    #   contents of the expected value, and if those are bitwise equal, replaces the former with desired (performs
    #   read-modify-write operation).
    #
    #   The result of the comparison: `true` if the current boolean was equal to expected, `false` otherwise.
    #
    #   @see https://en.cppreference.com/w/c/atomic/atomic_compare_exchange
    #
    #   @param expected [Boolean]
    #   @param desired [Boolean]
    #   @return [Boolean]
    #   @api private
    #
    # @!attribute [r] value
    #   @return [Boolean] the current cached value
    #   @api private
    class AtomicBool
      # @return [String]
      def to_s
        "BM::Cancellation::AtomicBool(#{value})"
      end
      alias inspect to_s
    end
  end
end

require 'bm_cancellation_atomic_bool/bm_cancellation_atomic_bool'
