desc "add article fields retrospectively."
task :retro => :environment do
  wp = Rubypress::Client.new(
    :host => "techinasia.com", 
    :username => Figaro.env.techinasia_username, 
    :password => Figaro.env.techinasia_password
  )
	articles = Article.all
	count = 0
	articles.each do |article|
		wp_data = wp.getPost(
			blog_id: "0",
			filter: {link: article["url"]},
			fields: ["terms"]
		)
		if article["tags"].blank? == true
			article["tags"] = wp_data["terms"]
			count += 1
			puts count
		end
	end
end