# Yamshik

Unified interface to Russian delivery services (CDEK, Boxberry, Russian Post, 5Post, Yandex Delivery, ...) — think `active_shipping`, but for Russia.

Yamshik is the **core gem**: it defines the domain model (parcels, places, items, tracking events), the carrier contract, the result/error model and the HTTP plumbing (retries, circuit breaker). Carrier integrations live in separate plugin gems:

- [yamshik-cdek](https://github.com/Kroch4ka/yamshik-cdek) — CDEK (in progress)

> Status: early development. See [DESIGN.md](DESIGN.md) (RU) for the architecture decisions.

## Installation

```bash
bundle add yamshik
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install yamshik
```

## Usage

TODO: usage instructions will appear with the first carrier plugin.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Kroch4ka/yamshik. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
