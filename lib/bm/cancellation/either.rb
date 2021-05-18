# frozen_string_literal: true

module BM
  module Cancellation
    # Combination of the left and the right cancellations it behaves like an ordinary cancellation.
    #
    # @!attribute left [r]
    #   @return [Cancellation]
    #   @api private
    #
    # @!attribute right [r]
    #   @return [Cancellation]
    #   @api private
    class Either
      include Cancellation

      attr_reader :left, :right, :reason

      # @param left [Cancellation]
      # @param right [Cancellation]
      #
      # @api private
      def initialize(left:, right:)
        @left = left
        @right = right

        @reason = if left.reason == right.reason
                    left.reason
                  else
                    "Either of [#{left.reason}] or [#{right.reason}]"
                  end
      end

      # Is any of the left or the right cancellations are cancelled
      #
      # @return [Boolean]
      def cancelled?
        @left.cancelled? || @right.cancelled?
      end
      alias expired? cancelled?

      # Checks that any of left or right cancellations are cancelled
      #
      # @raise [ExceptionCancelled] when the one of left or right cancellations are cancelled
      # @return [nil]
      def check!
        @left.check! || @right.check!
      end

      # Returns a minimum value of the left and the right expirations
      #
      # @return [Float]
      def expires_after
        [@left.expires_after, @right.expires_after].min
      end
    end
  end
end
