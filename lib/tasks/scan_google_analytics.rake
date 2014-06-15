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
		filter :high_pageviews, &lambda {gte(:pageviews, 200)}
	end

	start_date = (Time.now - 1209600).to_date
	end_date = Time.now.to_date

	profile = service_account_user.profiles.first
	results = Pageviews.results(profile, start_date: start_date, end_date: end_date).high_pageviews(profile)
	article_count = results.count
	final_results = results.take(article_count)
	result_array = Array.new
	final_results.each do |result|
		stripped_pagepath = result["pagepath"].gsub(/\/\?.*/, "/")
		stripped_pagepath[0] = ''
		unique = true
		result_array.each do |value|
			if value["pagepath"] == stripped_pagepath
				value["pageviews"] += result["pageviews"].to_i
				unique = false
			end
		end
		if unique == true
		  result_array.push({"pagepath" => stripped_pagepath, "pageviews" => result["pageviews"].to_i})
		end
	end
	articles = Article.all
	result_array.each do |result|
		articles.each do |article|
			if article.url.include?(result["pagepath"]) && result["pagepath"] != ""
				article.pageviews = result["pageviews"]
				article.save
				puts "This article has #{article.pageviews} pageviews."
			end
		end
	end
end