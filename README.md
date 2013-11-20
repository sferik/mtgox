# Ruby wrapper for the Mt. Gox Trade API

[![Gem Version](https://badge.fury.io/rb/mtgox.png)][gem]
[![Build Status](https://secure.travis-ci.org/sferik/mtgox.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/sferik/mtgox.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/github/sferik/mtgox.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/sferik/mtgox/badge.png?branch=master)][coveralls]
[![Gittip](http://img.shields.io/gittip/sferik.png)][gittip]

[gem]: https://rubygems.org/gems/mtgox
[travis]: http://travis-ci.org/sferik/mtgox
[gemnasium]: https://gemnasium.com/sferik/mtgox
[codeclimate]: https://codeclimate.com/github/sferik/mtgox
[coveralls]: https://coveralls.io/r/sferik/mtgox
[gittip]: https://www.gittip.com/sferik/

Mt. Gox allows you to trade US Dollars (USD) for Bitcoins (BTC) or Bitcoins for
US Dollars.

## Installation
    gem install mtgox

To ensure the code you're installing hasn't been tampered with, it's
recommended that you verify the signature. To do this, you need to add my
public key as a trusted certificate (you only need to do this once):

    gem cert --add <(curl -Ls https://raw.github.com/sferik/mtgox/master/certs/sferik.pem)

Then, install the gem with the high security trust policy:

    gem install mtgox -P HighSecurity

## Executable
After installing the gem, you can get the current price for 1 BTC in USD by
typing `btc` in your bash shell:

    $ btc
    50.00


## Documentation
[http://rdoc.info/gems/mtgox][documentation]

[documentation]: http://rdoc.info/gems/mtgox

## Usage Examples
```ruby
require 'rubygems'
require 'mtgox'

# Fetch the latest price for 1 BTC in USD
puts MtGox.ticker.sell

# Fetch open asks
puts MtGox.asks

# Fetch open bids
puts MtGox.bids

# Fetch the last 48 hours worth of trades (takes a minute)
puts MtGox.trades

# Certain methods require authentication
MtGox.configure do |config|
  config.key = YOUR_MTGOX_KEY
  config.secret = YOUR_MTGOX_SECRET
end

# Fetch your current balance
puts MtGox.balance

# Place a limit order to buy one bitcoin for $0.011
MtGox.buy! 1.0, 0.011

# Place a limit order to sell one bitcoin for $100
MtGox.sell! 1.0, 100.0

# Place a market order to sell one bitcoin
MtGox.sell! 1.0, :market

# Cancel order #1234567890
MtGox.cancel 1234567890

# Withdraw 1 BTC from your account
MtGox.withdraw! 1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"

# Switch to sending 'tonce' rather than 'nonce'
MtGox.nonce_type = :tonce
```

## Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0

If something doesn't work on one of these interpreters, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be responsible for providing patches in a timely
fashion. If critical issues for a particular implementation exist at the time
of a major release, support for that Ruby version may be dropped.

## Copyright
Copyright (c) 2011-2013 Erik Michaels-Ober. See [LICENSE][] for details.

[license]: LICENSE.md
