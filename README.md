# ActiveRecord PostgreSQL Fallback Adapter

[![Build Status](https://api.travis-ci.org/pascalh1011/activerecord-postgresql-fallback-adapter.png)](https://travis-ci.org/pascalh1011/activerecord-postgresql-fallback-adapter)

## What is this?

This is an ActiveRecord adapter that extends the out-the-box PostgreSQL adapter supplied with Rails to allow specifying multiple fallback hosts to the database configuration. Connections will be load balanced across these hosts, and any unhealthy hosts will be routed to the remaining healthy hosts via retries.

## When should I use this?

Main article: [some article](http://google.com)

Some use cases for having multiple database connection endpoints:

* Load balancing across multiple connection pooling instances (such as pgbouncer)
* Improving MTTR (mean time to recovery) by using multiple read-only replicas for parts of the application (such as with [octopus](https://github.com/thiagopradi/octopus))
* Multi-master setups such as [Postgres-BDR](http://bdr-project.org/docs/stable/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-postgresql-fallback-adapter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-postgresql-fallback-adapter

## Usage

This adapter is 100% compatible with the default `activerecord-postgresql-adapter`, and you can simply change the adapter in `config/database.yml`.

To enable the load balancing and fallback features, simply specify multiple hosts using DNS or IP addresses:

### Before

```yaml
production:
  adapter: postgresql
  host: some.single.point.of.failure.com
```

### After

```yaml
production:
  adapter: postgresql_fallback
  host: 
    - 'host1.com'
    - 'host2.com'
    - '10.1.1.7'
```

## What about PostgreSQL 10?

PostgreSQL 10.0 introduces [multi host connection strings](http://paquier.xyz/postgresql-2/postgres-10-multi-host-connstr/) which also allows specifying multiple fallback hosts and this is now supported internally by libpq. There are however some caveats:

* You need a bleeding edge PG version
* Clients need to be compiled with the newer libpq
* Connections in ActiveRecord remain dead when an upstream host goes offline and this requires forcing a reconnection (eg. via bouncing Unicorn)
* Does not load balance

## Tested Rails Versions

Unfortunately the bundled database adapters can't be extended without a small amount of duplication, so the implementation is slighly coupled to the Rails version.

The following Rails versions are tested against:

* 4.2.x
* 5.0.x
* 5.1.x

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake` to run the tests. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in the gemspec, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pascalh1011/activerecord-pg-multi-host-adapter.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
