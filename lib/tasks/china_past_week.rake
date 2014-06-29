desc "Updates Top articles about China in the past week"
task :china_past_week => :environment do
  wp = Rubypress::Client.new(
  	:host => "techinasia.com", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )

  puts "login successful"

  articles = Article.where("date >= ?", 7.days.ago.to_date).where("china" => true).order(pageviews: :desc)

  post_content = "<img src=\"http://cdn.techinasia.com/wp-content/uploads/2013/03/China-tech-news-this-week-v8.jpg\" alt=\"CTW - China tech news this week\" width=\"1000\" height=\"593\" />
    <p>Here are the most read stories about China's tech developments in the past week.</p><hr />"

  articles.each do |article| 
    post_content += "<h3><a href=\"#{article["url"]}\">#{article["headline"]}</a></h3><p>"
    if article["excerpt"].blank? == false
      post_content += "#{article["excerpt"]}</p><hr />"
    else
      post_content += "#{article["intro"]}</p><hr />"
    end
  end

  post_content += "This page refreshes everyday. Check back regularly to see what the top stories are. For our full spread of China coverage, you might like to subscribe to our <a href=\"http://www.techinasia.com/tag/china/feed/\">China RSS feed</a>."

  wp_articles = wp.editPost(
    post_id: 182690, 
    content: {
      post_content: post_content
    }
  )
end