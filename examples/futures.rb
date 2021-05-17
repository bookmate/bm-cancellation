# frozen_string_literal: true

require 'bundler/setup'
require 'bm/cancellation'
require 'concurrent'

def checked(cancellation, semaphore)
  semaphore.acquire
  return :cancelled if cancellation.cancelled?

  yield
ensure
  semaphore.release
end

def map(array, cancellation) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  max_two = Concurrent::Semaphore.new(2)
  cancel, on_error = cancellation.new
  jobs_completed = Concurrent::CountDownLatch.new(array.size)

  futures = array.map do |item|
    Concurrent::Promises
      .future(cancel, max_two) { checked(_1, _2) { yield item } }
      .on_rejection!(&on_error)
      .on_resolution! { jobs_completed.count_down }
  end

  jobs_completed.wait

  futures.each do |future|
    puts "rejected #{future.reason.inspect}" if future.rejected?
    puts "resolved #{future.value.inspect}"
  end
end

def success(item)
  item
end

def failure(item)
  sleep 1
  item > 3 ? raise('boom') : item
end

cancellation, control = BM::Cancellation.new
Signal.trap('INT', &control)

map((1..10), cancellation, &method(:success))
map((1..10), cancellation, &method(:failure))
