# frozen_string_literal: true

# frozen_string_literal: true

require 'mkmf'

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']
CONFIG['cflags'] = "#{CONFIG['cflags']} -std=c11"

create_header
create_makefile 'bm_cancellation_atomic_bool/bm_cancellation_atomic_bool'
