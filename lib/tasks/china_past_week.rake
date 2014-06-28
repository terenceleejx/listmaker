desc "Updates Top articles about China in the past week"
task :china_past_week => :environment do
  wp = Rubypress::Client.new(
  	:host => "techinasia.com", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )

  puts "login successful"

  puts articles = Article.where("date >= ?", 7.days.ago.to_date).where("china" => true)

  wp_articles = wp.editPost(
    post_id: 182690, 
    content: {
      post_content: DateTime.now.to_s
    }
  )
end