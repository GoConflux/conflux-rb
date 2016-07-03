require 'net/http'
require 'net/https'
require 'uri'
require 'json'

module Conflux
  module Helpers
    extend self

    def ask_for_basic_creds
      # Ask for Conflux Credentials
      puts 'Enter your Conflux credentials.'

      # Email:
      print 'Email: '
      email = allow_user_response

      # Password
      print 'Password (typing will be hidden): '

      password = running_on_windows? ? ask_for_password_on_windows : ask_for_password

      { email: email, password: password }
    end

    def ask_for_password_on_windows
      require 'Win32API'
      char = nil
      password = ''

      while char = Win32API.new('msvcrt', '_getch', [ ], 'L').Call do
        break if char == 10 || char == 13 # received carriage return or newline
        if char == 127 || char == 8 # backspace and delete
          password.slice!(-1, 1)
        else
          # windows might throw a -1 at us so make sure to handle RangeError
          (password << char.chr) rescue RangeError
        end
      end

      puts
      password
    end

    def ask_for_password
      begin
        echo_off  # make the password input hidden
        password = allow_user_response
        puts
      ensure
        echo_on  # flip input visibility back on
      end

      password
    end

    # Hide user input
    def echo_off
      with_tty do
        system 'stty -echo'
      end
    end

    # Show user input
    def echo_on
      with_tty do
        system 'stty echo'
      end
    end

    def with_tty(&block)
      return unless $stdin.isatty
      begin
        yield
      rescue
        # fails on windows
      end
    end

    def allow_user_response
      $stdin.gets.to_s.strip
    end

    def running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    def prompt_user_to_select_app(apps_map)
      answer = nil
      question = "\nWhich Conflux app does this project belong to?\n"

      # Keep asking until the user responds with one of the possible answers
      until !answer.nil?
        count = 0
        app_slugs = []

        puts question

        apps_map.each { |team, apps|
          puts "\n#{team}:\n\n"   # separate apps out by team for easier selection

          apps.each { |slug|
            count += 1
            puts "(#{count}) #{slug}"
            app_slugs << slug
          }
        }

        puts "\n"

        response = allow_user_response

        # it's fine if the user responds with an exact app slug
        if app_slugs.include?(response)
          answer = response

          # otherwise, they can just respond with the number next to the app they wish to choose
        else
          response_int = response.to_i rescue 0
          answer = app_slugs[response_int - 1 ]if response_int > 0
        end

        question = "\nSorry I didn't catch that. Can you respond with the number that appears next to your answer?"
      end

      answer
    end

    def error(msg = '')
      $stderr.puts(msg)
      exit(1)
    end

    def host_url
      ENV['CONFLUX_HOST'] || 'http://api.goconflux.com'
    end

    def http
      uri = URI.parse(host_url)
      Net::HTTP.new(uri.host, uri.port)
    end

    def form_request(net_obj, route, data, headers, error_message)
      data ||= {}
      headers ||= {}
      route = data.empty? ? route : "#{route}?#{URI.encode_www_form(data)}"
      request = net_obj.new("/api#{route}")
      request.add_field('Content-Type', 'application/x-www-form-urlencoded')
      add_headers(request, headers)
      response = http.request(request)
      handle_json_response(response, error_message)
    end

    def json_request(net_obj, route, data, headers, error_message)
      data ||= {}
      headers ||= {}
      request = net_obj.new("/api#{route}")
      request.add_field('Content-Type', 'application/json')
      add_headers(request, headers)
      request.body = data.to_json
      response = http.request(request)
      handle_json_response(response, error_message)
    end

    def add_headers(request, headers)
      headers.each { |key, val| request.add_field(key, val) }
    end

    def handle_json_response(response, error_message)
      if response.code.to_i == 200
        JSON.parse(response.body) rescue {}
      else
        error(error_message)
      end
    end

    def conflux_folder_path
      "#{Dir.pwd}/.conflux/"
    end

    def conflux_manifest_path
      File.join(conflux_folder_path, 'manifest.json')
    end

  end
end