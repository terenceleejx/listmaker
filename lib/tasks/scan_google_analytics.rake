desc "Scan Tech in Asia's Google Analytics for pageview stats"
task :scan_GA => :environment do
	client = OAuth2::Client.new(Figaro.env.legato_oauth_client_id, Figaro.env.legato_oauth_secret_key, {
	  :authorize_url => 'https://accounts.google.com/o/oauth2/auth',
	  :token_url => 'https://accounts.google.com/o/oauth2/token'
	})
	client.auth_code.authorize_url({
	  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
	  :redirect_uri => 'http://localhost',
	  :access_type => 'offline'
	})
	access_token = client.auth_code.get_token(Figaro.env.legato_oauth_auth_code, :redirect_uri => 'http://localhost')

	response_json = access_token.get('https://www.googleapis.com/analytics/v3/management/accounts').body

	JSON.parse(response_json)
end