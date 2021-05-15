# frozen_string_literal: true

require 'bundler/setup'

require 'digest/sha2'
require 'bm/cancellation'
require 'concurrent-edge'

# Spawn a tack
# @param cancellation [BM::Cancellation]
# @param name [String, Symbol]
# @param channel [Concurrent::Channel]
# @return [Concurrent::Channel]
def go_until_cancelled(cancellation, name, channel)
  Concurrent::Channel.go do
    yield until cancellation.cancelled?

    puts "#{name} interrupted by [#{cancellation.name}]"
    channel.close
  end
  channel
end

# Performs a tick each 0.1s
#
# @param cancellation [BM::Cancellation]
# @param capacity [Integer]
# @return [Concurrent::Channel]
def ticker(cancellation, capacity:)
  number = 0
  ch = Concurrent::Channel.new(capacity: capacity)
  go_until_cancelled(cancellation, :ticker, ch) do
    number += 1 if ch.offer(number)
    sleep 0.3
  end
end

# Reads 1k from `/dev/urandom`
#
# @param cancellation [BM::Cancellation]
# @param capacity [Integer]
# @param input [Concurrent::Channel]
# @return [Concurrent::Channel]
def reader(cancellation, capacity:, input:)
  ch = Concurrent::Channel.new(capacity: capacity)
  go_until_cancelled(cancellation, :reader, ch) do
    tick = ~input
    data = File.read('/dev/urandom', 1024).tap { sleep 0.2 }
    ch << [tick, data]
  end
end

# Performs SHA256 hashes for input
#
# @param cancellation [BM::Cancellation]
# @param capacity [Integer]
# @param input [Concurrent::Channel]
# @return [Concurrent::Channel]
def hasher(cancellation, capacity:, input:)
  ch = Concurrent::Channel.new(capacity: capacity)
  go_until_cancelled(cancellation, :hasher, ch) do
    tick, chunk = ~input
    digest = Digest::SHA256.hexdigest(chunk).tap { sleep 0.1 }
    ch << [tick, digest]
  end
end

#
# Run the pipeline and stop it on `SIGINT` or after 10s
#
cancellation = BM::Cancellation.signal('Signal').then do |(signal, control)|
  Signal.trap('INT') { Thread.new { control.cancel } }
  signal.with_deadline('Timeout', seconds_from_now: 10)
end

capacity = 10
ticker = ticker(cancellation, capacity: capacity)
reader = reader(cancellation, capacity: capacity, input: ticker)
hasher = hasher(cancellation, capacity: capacity, input: reader)

hasher.each { pp _1 }
