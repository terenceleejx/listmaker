desc "add article fields retrospectively."
task :retro => :environment do
  wp = Rubypress::Client.new(
    :host => "techinasia.com", 
    :username => Figaro.env.techinasia_username, 
    :password => Figaro.env.techinasia_password
  )
	articles = Article.all
	count = 0
	wp_articles = wp.getPosts(
		blog_id: "0",
		filter: {post_type: "post", post_status: "publish", orderby: "date", order: "DESC", number: 2700}, 
		#2700 is near the max before an error occurs
		fields: ["post_id", "link"]
	)
	articles.each do |article|
		if article["tags"].blank? == true
			correct_id = String.new
			wp_articles.each do |wp_article|
				if wp_article["link"] == article["url"]
					correct_id = wp_article["post_id"]
					break
				end
			end
			puts correct_id
		  if correct_id.blank? == false
				correct_article = wp.getPost(
					blog_id: "0",
					post_id: correct_id,
					fields: ["terms"]
				)
				count += 1
				article["tags"] = correct_article["terms"]
				article.save
				puts "Tags added to #{count} articles."
			end
	  end
	end
end