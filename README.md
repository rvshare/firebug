# Firebug [![CircleCI](https://circleci.com/gh/afrase/firebug/tree/master.svg?style=svg)](https://circleci.com/gh/afrase/firebug/tree/master)

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

encrypted = Firebug.encrypt(key, data)
decrypted = Firebug.decrypt(key, encrypted)

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

## Todo

- [x] Add Rails session store support.
- [ ] Support for serializing and unserializing classes.
- [x] Add validation to unserializer. e.g. make sure length of string or
      size of array is correct.
- [ ] Complete this readme.
- [ ] Create documentation.

## Contributing

Bug reports and pull requests are welcome on GitHub at
[https://github.com/afrase/firebug](https://github.com/afrase/firebug.)

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
