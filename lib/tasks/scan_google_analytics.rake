desc "Scan Tech in Asia's Google Analytics for pageview stats"
task :scan_GA => :environment do
	require 'google/api_client'
	def service_account_user(scope="https://www.googleapis.com/auth/analytics.readonly")
	   client = Google::APIClient.new(
	     :application_name => "Listmaker",
	     :application_version => "2.0"
	   )
	   key = OpenSSL::PKey::RSA.new(Figaro.env.google_private_key, "notasecret")
	   service_account = Google::APIClient::JWTAsserter.new(Figaro.env.google_app_email_address, scope, key)
	   client.authorization = service_account.authorize
	   oauth_client = OAuth2::Client.new("", "", {
	      :authorize_url => 'https://accounts.google.com/o/oauth2/auth',
	      :token_url => 'https://accounts.google.com/o/oauth2/token'
	   })
	   token = OAuth2::AccessToken.new(oauth_client, client.authorization.access_token)
	   Legato::User.new(token)
	end

	class Pageviews
		extend Legato::Model

		metrics :pageviews
		dimensions :pagepath
		filter :one_pagepath, &lambda {|pagepath| matches(:pagepath, pagepath)}
	end

	profile = service_account_user.profiles.first
	results = Pageviews.results(profile)
	puts results.one_pagepath("/meet-hope-technik-singapores-engineering-commandos/", profile).first

end