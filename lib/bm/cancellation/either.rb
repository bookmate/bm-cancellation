# frozen_string_literal: true

module BM
  class Cancellation
    # Combination of the left and the right cancellations it behaves like an ordinary cancellation.
    #
    # @!attribute left [r]
    #   @return [Cancellation]
    #   @api private
    #
    # @!attribute right [r]
    #   @return [Cancellation]
    #   @api private
    class Either < Cancellation
      attr_reader :left, :right

      # @param left [Cancellation]
      # @param right [Cancellation]
      #
      # @api private
      def initialize(left:, right:)
        super()
        @left = left
        @right = right
        @name = "(#{left.name} | #{right.name})".freeze
      end

      # Checks that either of left or right are cancelled
      #
      # @return [Boolean]
      def cancelled?
        @left.cancelled? || @right.cancelled?
      end

      # Checks that either of left or right are cancelled
      #
      # @raise [ExceptionCancelled] when the one of left or right cancellations are cancelled
      # @return [nil]
      def check!
        @left.check! || @right.check!
      end

      # Returns a minimum value of left and right expirations
      #
      # @return [Float]
      def expires_after
        [@left.expires_after, @right.expires_after].min
      end

      # The name is depending on what cancellation is cancelled.
      #
      # If it's right return right's name or if it's left return left's name,
      # otherwise return a combined name.
      #
      # @return [String]
      def name
        return @right.name if @right.cancelled? # __important__ the right is first
        return @left.name if @left.cancelled?   # the left is second

        @name
      end
    end
  end
end