require 'conflux/version'
require 'rest-client'
require 'json'

module Conflux
  require 'conflux/railtie' if defined?(Rails)
  extend self

  config_vars_path = File.join(Dir.pwd, 'configs.yml')

  if File.exists?(config_vars_path)
    require 'yaml'
    configs = YAML::load_file(config_vars_path) rescue {}
    configs.each { |key, val|
      ENV[key] = val if !ENV.key?(key)
    }
  end

  APPLICATION_YAML_PATH = File.join(Dir.pwd, 'config', 'application.yml')
  MANIFEST_PATH = File.join(Dir.pwd, '.conflux', 'manifest.json')
  CONFLUX_YAML_PATH = File.join(Dir.pwd, '.conflux', 'conflux.yml')
  CONFLUX_USER = 'CONFLUX_USER'
  CONFLUX_APP = 'CONFLUX_APP'

  def start!
    fetch_configs if configured_for_conflux
  end

  private

  def configured_for_conflux
    if ENV[CONFLUX_USER] && ENV[CONFLUX_APP]
      @creds_preset = true

      @credentials = {
        'CONFLUX_USER' => ENV[CONFLUX_USER],
        'CONFLUX_APP' => ENV[CONFLUX_APP]
      }
    else
      @credentials = File.exists?(MANIFEST_PATH) ? manifest_creds : {}
    end

    @credentials[CONFLUX_USER] && @credentials[CONFLUX_APP]
  end

  def manifest_creds
    manifest = JSON.parse(File.read(MANIFEST_PATH)) rescue {}
    configs = manifest['configs'] || {}

    {
      'CONFLUX_USER' => configs[CONFLUX_USER],
      'CONFLUX_APP' => configs[CONFLUX_APP]
    }
  end

  def fetch_configs
    RestClient.get("#{conflux_url}/api/keys", headers) do |response|
      if response.code == 200
        configs = JSON.parse(response.body) rescue []
        set_configs(configs, !@creds_preset)
      end
    end
  end

  def set_configs(configs_map, add_to_yml)
    # Get application.yml file to make sure config vars aren't already there
    @app_configs = YAML::load_file(APPLICATION_YAML_PATH) rescue {}

    if add_to_yml
      File.open(CONFLUX_YAML_PATH, 'w+') do |f|
        f.write(yaml_header)

        configs_map.each { |addon_name, configs|
          f.write("\n\n# #{addon_name}") if !configs.empty?

          configs.each { |config|
            key = config['name']
            value = config['value']
            description = config['description']

            # if the key already exists, let the developer know that it has
            # been overwritten and to what value
            if key_already_set?(key)
              description = description.nil? ? '' : " ... #{description}"
              line = "\n# #{key}  <-- (Overwritten) #{description}"
            else
              description = description.nil? ? '' : " # #{description}"
              line = "\n#{key}#{description}"
              ENV[key] = value
            end

            f.write(line)
          }
        }
      end
    else
      configs_map.each { |addon_name, configs|
        configs.each { |config|
          key = config['name']
          value = config['value']

          ENV[key] = value if !key_already_set?(key)
        }
      }
    end
  end

  def key_already_set?(key)
    ENV.key?(key) || @app_configs.key?(key) || (@app_configs[Rails.env] || {}).key?(key)
  end

  def headers
    {
      'Conflux-User' => @credentials[CONFLUX_USER],
      'Conflux-App' => @credentials[CONFLUX_APP]
    }
  end

  def conflux_url
    ENV['CONFLUX_HOST'] || 'http://api.goconflux.com'
  end

  def yaml_header
    "\n# CONFLUX CONFIG VARS:\n\n" \
    "# All config vars seen here are in use and pulled from Conflux.\n" \
    "# If any are ever overwritten, they will be marked with \"Overwritten\"\n" \
    "# If you ever wish to overwrite any of these, do so inside of a config/application.yml file."
  end

end
