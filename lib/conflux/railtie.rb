require 'conflux'
require 'rails'

module Conflux
  class Railtie < ::Rails::Railtie
    railtie_name :conflux
    # Hooking into `to_prepare` because it runs BEFORE the config/initializers
    # files but AFTER any other railties hooking into `before_configuration` - which
    # is what the popular gem "figaro" uses. This allows for Conflux config vars to be
    # more easily overwritten if desired, by simply using figaro and manually specifying
    # config vars in your config/application.yml file.
    config.before_configuration do
      Conflux.start!
    end

    rake_tasks do
      load 'tasks/conflux.rake'
    end
  end
end