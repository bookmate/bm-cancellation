# frozen_string_literal: true

require 'bm/cancellation/version'
require 'bm/cancellation/atomic_bool'
require 'bm/cancellation/interface'
require 'bm/cancellation/signal'
require 'bm/cancellation/deadline'
require 'bm/cancellation/either'

module BM
  # Provides tools for cooperative cancellation and timeouts management.
  module Cancellation
    class << self
      # A cancellation object backed by atomic boolean. Becomes cancelled when an associated {Control}
      # has done.
      #
      # @example Usage
      #   cancellation, control = BM::Cancellation.new
      #   Signal.trap('INT', &control)
      #
      #   do_work until cancel.cancelled?
      #
      # @return [Control] a cancellation and its control handler
      def new
        Control.new.freeze
      end

      # A cancellation object that expires after certain period of time.
      #
      # @example Usage
      #   cancellation = BM::Cancellation.timeout(seconds: seconds)
      #   do_work until cancellation.cancelled?
      #
      # @example Joins with another cancellation
      #   cancellation.timeout(seconds: 5).then do |timeout|
      #     do_work until timeout.expired?
      #   end
      #
      # @param seconds [Numeric] is a number seconds after the timeout will be expired
      # @param clock [#time] override a time source (non public)
      # @return [Cancellation]
      def timeout(seconds:, clock: Deadline::Clock)
        Deadline.new(seconds_from_now: seconds, clock: clock).freeze
      end
    end
  end
end
