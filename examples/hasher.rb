# frozen_string_literal: true

require 'bundler/setup'

require 'digest/sha2'
require 'bm/cancellation'

# Performs a tick each 0.1s
#
# @param cancellation [BM::Cancellation]
# @return [Enumerator]
def ticker(cancellation)
  Enumerator.new do |stream|
    number = 0
    until cancellation.cancelled?
      number += 1
      stream.yield(number)
    end

    puts 'ticker interrupted'
  end
end

# Reads 1k from `/dev/urandom`
#
# @param cancellation [BM::Cancellation]
# @return [Lambda]
def reader(cancellation)
  lambda do |tick|
    next puts('reader interrupted') if cancellation.cancelled?

    data = File.read('/dev/urandom', 1024).tap { sleep 0.2 }
    [tick, data]
  end
end

# Performs SHA256 hashes for input
#
# @param cancellation [BM::Cancellation]
# @return [Lambda]
def hasher(cancellation)
  lambda do |(tick, chunk)|
    next puts('hasher interrupted') if cancellation.cancelled?

    digest = Digest::SHA256.hexdigest(chunk).tap { sleep 0.1 }
    [tick, digest]
  end
end

#
# Run the pipeline and stop it on `SIGINT` or after 10s
#
cancellation = BM::Cancellation.new.then do |(cancel, control)|
  Signal.trap('INT', &control)
  cancel.timeout(seconds: 5)
end

pp ticker(cancellation)
  .lazy
  .map(&reader(cancellation))
  .map(&hasher(cancellation))
  .reject(&:nil?)
  .reduce(:+)
