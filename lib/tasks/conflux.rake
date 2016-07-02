require 'json'
require 'rest-client'
require 'fileutils'
require 'conflux/helpers'

namespace :conflux do

  desc 'Set which conflux app to use for the current directory'
  task :set_app do
    helpers = Conflux::Helpers
    creds = helpers.ask_for_basic_creds

    RestClient.post(helpers.url('/users/apps_basic_auth'), creds) do |response|
      body = helpers.handle_json_response(response, 'Authentication failed.')

      # Ask which app user wants to use:
      app_slug = helpers.prompt_user_to_select_app(body['apps_map'])

      RestClient.get(helpers.url("/apps/manifest?app_slug=#{app_slug}"), { 'Conflux-User' => body['token'] }) do |response|
        resp = helpers.handle_json_response(response, 'Request failed.')
        manifest_json = resp['manifest']

        # Create .conflux/ folder if doesn't already exist
        FileUtils.mkdir_p(helpers.conflux_folder_path) if !File.exists?(helpers.conflux_folder_path)

        puts 'Configuring manifest.json...'

        # Write this app info to a new manifest.json file for the user
        File.open(helpers.conflux_manifest_path, 'w+') do |f|
          f.write(JSON.pretty_generate(manifest_json))
        end

        puts "Successfully connected project to conflux app: #{app_slug}"
        puts "The 'conflux' ruby gem wasn't automatically installed...Make sure it's installed if you haven't already done so."
      end
    end

  end

end