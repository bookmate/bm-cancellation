# frozen_string_literal: true

require 'bundler/setup'

require 'bm/cancellation/atomic_bool'
require 'concurrent'
require 'benchmark'

def iter_using_concurrent_ruby(iterations, flag: nil)
  flag ||= Concurrent::AtomicBoolean.new(false)
  iterations.times do
    next_val = !flag.value
    next_val ? flag.make_false : flag.make_true
  end
end

def iter_using_cancellation(iterations, flag: nil)
  flag ||= BM::Cancellation::AtomicBool.new(false)
  iterations.times do
    next_val = !flag.value
    flag.swap(!next_val, next_val)
  end
end

def threads_using_concurrent_ruby(iterations, threads)
  ths = []
  flag = Concurrent::AtomicBoolean.new(false)
  iterations /= threads

  threads.times do
    ths << Thread.new { iter_using_concurrent_ruby(iterations, flag: flag) }
  end

  ths.each(&:join)
end

def threads_using_cancellation(iterations, threads)
  ths = []
  flag = BM::Cancellation::AtomicBool.new(false)
  iterations /= threads

  threads.times do
    ths << Thread.new { iter_using_cancellation(iterations, flag: flag) }
  end

  ths.each(&:join)
end

def setup
  iter_using_cancellation(1_000)
  iter_using_concurrent_ruby(1_000)

  GC.disable
end

def bench
  iterations = 1_000_000

  Benchmark.bm(40) do |x|
    x.report('Concurrent::AtomicBoolean') { iter_using_concurrent_ruby(iterations) }
    x.report('BM::Cancellation::AtomicBool') { iter_using_cancellation(iterations) }

    [2, 4, 8].each do |threads|
      x.report("Concurrent::AtomicBoolean    [#{threads} threads]") do
        threads_using_concurrent_ruby(iterations, threads)
      end
      x.report("BM::Cancellation::AtomicBool [#{threads} threads]") do
        threads_using_cancellation(iterations, threads)
      end
    end
  end
end

setup
bench
