# frozen_string_literal: true

require 'bm/cancellation/version'
require 'bm/cancellation/atomic_bool'
require 'bm/cancellation/interface'
require 'bm/cancellation/cancel'
require 'bm/cancellation/deadline'
require 'bm/cancellation/either'

module BM
  # Provides tools for cooperative cancellation
  module Cancellation
    class << self
      # A cancellation object backed by atomic boolean. Becomes cancelled when an associated {Control}
      # has done.
      #
      # @example Usage
      #   cancellation, control = BM::Cancellation.cancel('MyWork')
      #   Signal.trap('INT', &control)
      #
      #   do_work until cancellation.cancelled?
      #
      # @param name [String] is a name of cancellation
      # @return [(Cancellation, Control)] a cancellation and its control handler
      def cancel(name)
        control, atomic = Control.new
        cancellation = Cancel.new(name: name, atomic: atomic)
        [cancellation, control].map(&:freeze)
      end

      # A cancellation object that expires after certain period of time.
      #
      # @example Usage
      #   cancellation = BM::Cancellation.timeout('MyWork', seconds: seconds)
      #   do_work until cancellation.cancelled?
      #
      # @example Joins with another cancellation
      #   cancellation.with_timeout('MyWork', seconds: 5).then do |timeout|
      #     do_work until timeout.expired?
      #   end
      #
      # @param name [String] is a name of cancellation
      # @param seconds [Numeric] is a number seconds after the timeout will be expired
      # @param clock [#time] override a time source (non public)
      # @return [Cancellation]
      def timeout(name, seconds:, clock: Deadline::Clock)
        Deadline.new(name: name, seconds_from_now: seconds, clock: clock).freeze
      end
    end
  end
end
