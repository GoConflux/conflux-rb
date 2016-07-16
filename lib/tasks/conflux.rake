require 'json'
require 'rest-client'
require 'fileutils'
require 'conflux/helpers'

namespace :conflux do

  desc 'Set which conflux bundle to use for the current directory'
  task :use_bundle do
    helpers = Conflux::Helpers
    creds = helpers.ask_for_basic_creds

    auth_response_body = helpers.json_request(
      Net::HTTP::Post,
      '/users/apps_basic_auth',
      creds,
      nil,
      'Authentication failed.'
    )

    # Ask which app the user wants to use:
    app_slug = helpers.prompt_user_to_select_app(auth_response_body['apps_map'])

    manifest_response_body = helpers.form_request(
      Net::HTTP::Get,
      '/apps/manifest',
      { app_slug: app_slug },
      { 'Conflux-User' => auth_response_body['token'] },
      'Connecting to Conflux bundle failed.'
    )

    manifest_json = manifest_response_body['manifest']

    # Create .conflux/ folder if doesn't already exist
    FileUtils.mkdir_p(helpers.conflux_folder_path) if !File.exists?(helpers.conflux_folder_path)

    puts 'Configuring manifest.json...'

    # Write this app info to a new manifest.json file for the user
    File.open(helpers.conflux_manifest_path, 'w+') do |f|
      f.write(JSON.pretty_generate(manifest_json))
    end

    puts "Successfully connected project to conflux bundle: #{app_slug}"
    puts "The 'conflux' ruby gem wasn't automatically installed...Make sure it's installed if it's not already."
  end

end