# Firebug [![CircleCI](https://circleci.com/gh/rvshare/firebug.svg?style=svg)](https://circleci.com/gh/rvshare/firebug)
[![Gem Version](https://badge.fury.io/rb/firebug.svg)](https://badge.fury.io/rb/firebug)

A gem for working with CodeIgniter sessions in ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firebug'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install firebug
```

To use the Rails session store, create an initializer file with:

```ruby
Firebug.configure do |config|
  config.key = 'encryption key'
  config.table_name = 'sessions'
end
```

And then set:

```ruby
Rails.application.config.session_store :code_igniter_store
```

If you are using Rails in API mode then you will need to set the middleware:

```ruby
Rails.application.config.middleware.use ActionDispatch::Session::CodeIgniterStore
```

## Usage

Serialize a ruby object to PHP's serialized format and unserialize a
PHP serialized string into a ruby object.

```ruby
ruby_obj = { foo: 'bar' }
serialized_obj = Firebug.serialize(ruby_obj) # => a:1:{s:3:"foo";s:3:"bar";}
result = Firebug.unserialize(serialized_obj) # => {:foo=>"bar"}

ruby_obj == result # => true
```

Encrypt and decrypt data.

```ruby
key = 'password'
data = 'super secret data'

encrypted = Firebug.encrypt(data, key)
decrypted = Firebug.decrypt(encrypted, key)

data == decrypted # => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the
version, push git commits and tags, and push the `.gem`file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
[https://github.com/rvshare/firebug](https://github.com/rvshare/firebug).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
