# Conflux Ruby gem

The Conflux Ruby gem is meant to be used in tandem with the [Conflux CLI](https://github.com/GoConflux/conflux-cli) to fetch your app's Conflux configs on boot of your Rails server by tying into a Railtie.

That Railtie can be found inside `lib/conflux/railtie.rb`

## Installation

**Note: If you've installed the Conflux CLI, it should have automatically installed the Conflux Ruby gem for you.**

If you need to install in manually for whatever reason, do one of the following:

Add this line to your application's Gemfile:

```ruby
gem 'conflux'
```

And then install it with bundler:

    $ bundle install

Or just use gem install:

    $ gem install conflux

## Contributing

To contribute to this repo, submit a pull request or raise an issue in the issues section with an appropriate issue tag.

## License

[MIT License](http://opensource.org/licenses/MIT).
