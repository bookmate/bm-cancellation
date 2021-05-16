# frozen_string_literal: true

require 'bm/cancellation/version'
require 'bm/cancellation/atomic_bool'
require 'bm/cancellation/interface'
require 'bm/cancellation/cancel'
require 'bm/cancellation/deadline'
require 'bm/cancellation/either'

module BM
  # Provides tools for cooperative cancellation
  class Cancellation
    class << self
      # Creates a new cancellation
      #
      # @example
      #   cancellation, control = BM::Cancellation.cancel('MyWork')
      #   Signal.trap('INT') { control.done }
      #
      #   do_work until cancellation.cancelled?
      #
      # @return [(Cancellation, Control)] a cancellation and its control handler
      def cancel(name)
        control, atomic = Control.new
        cancellation = Cancel.new(name: name, atomic: atomic)
        [cancellation, control].map(&:freeze)
      end

      # Creates a cancellation will be expire after certain period of time
      #
      # @example
      #   deadline = BM::Cancellation.timeout('Request', seconds: 2)
      #   do_request_with(deadline)
      #
      # @param name [String]
      # @param seconds [Numeric]
      # @param clock [#time] override a time source (non public)
      # @return [Cancellation]
      def timeout(name, seconds:, clock: Deadline::Clock)
        Deadline.new(name: name, seconds_from_now: seconds, clock: clock).freeze
      end
    end
  end
end
