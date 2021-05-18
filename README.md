# Bm::Cancellation

Provides tools for cooperative cancellation and timeouts management.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bm-cancellation'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install bm-cancellation

## Usage

Works until a `SIGINT` signal received:
```ruby
cancellation, control = BM::Cancellation.new
Signal.trap('INT', &control)
do_work until cancellation.cancelled?
```

Works until a `SIGINT` signal received or a timeout expired:
```ruby
cancellation, control = BM::Cancellation.new
Signal.trap('INT', &control)

cancellation.timeout('MyWork', seconds: 5).then do |timeout|
  do_work until timeout.expired?
end
```
For more complex cases see [examples directory][examples].

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on [GitHub][issues]. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct][code_of_conduct]

## License

The gem is available as open source under the terms of the [MIT License][mit_license].

## Code of Conduct

Everyone interacting in the Bm::Cancellation project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct][code_of_conduct].

[issues]: https://github.com/bookmate/bm-cancellation/issues
[code_of_conduct]: https://github.com/bookmate/bm-cancellation/blob/master/CODE_OF_CONDUCT.md
[mit_license]: https://opensource.org/licenses/MIT
[examples]: https://github.com/bookmate/bm-cancellation/tree/master/examples
