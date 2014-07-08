desc "Updates list articles"
task :update_articles => :environment do
  wp = Rubypress::Client.new(
  	:host => "techinasia.com", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )

  puts "login successful"

  ##China this week

  articles = Article.where("date >= ?", 7.days.ago.to_date).where("china" => true).order(pageviews: :desc)

  post_content = "<img src=\"http://cdn.techinasia.com/wp-content/uploads/2013/03/China-tech-news-this-week-v8.jpg\" alt=\"CTW - China tech news this week\" width=\"1000\" height=\"593\" />
    <p>Here are the most read stories about China's tech developments in the past week.</p><hr />"

  count = 0

  articles.each do |article| 
    if article["headline"] != "10 must-read tech stories in China this week" && article["pageviews"].blank? == false
      post_content += "<h3>#{count + 1} <a href=\"#{article["url"]}\">#{article["headline"]}</a></h3><p>"
      if article["excerpt"].blank? == false 
        post_content += "#{article["excerpt"]}</p><hr />"
      else
        post_content += "#{article["intro"]}</p><hr />"
      end
      puts "#{article["headline"]}"
      count += 1
    end
    break if count == 10
  end

  post_content += "For our full spread of China coverage, you might like to subscribe to our <a href=\"http://www.techinasia.com/tag/china/feed/\">China RSS feed</a>."

  wp_articles = wp.editPost(
    post_id: 183027, 
    content: {
      post_date: DateTime.now - 1.day,
      post_content: post_content,
      post_excerpt: "Here are the most read stories about China's tech developments in the past week."
    }
  )

  ##Hottest stories

  articles = Article.where("date >= ?", 7.days.ago.to_date).order(pageviews: :desc)

  post_content = "<img class=\"aligncenter size-full wp-image-174555\" src=\"http://cdn.techinasia.com/wp-content/uploads/2014/04/SOTW-weekend-reading.jpg?8346b2\" alt=\"SOTW - weekend reading\" width=\"720\" height=\"309\" />
    <p>Miss out on the best Asia tech news from the past seven days? Worry not, we've got you covered. Here's our regular roundup of the week's hottest stories.</p><hr />"

  count = 0

  articles.each do |article| 
    if article["headline"] != "20 of our hottest tech stories for your weekend reading" && article["pageviews"].blank? == false
      post_content += "<h3>#{count + 1} <a href=\"#{article["url"]}\">#{article["headline"]}</a></h3><p>"
      if article["excerpt"].blank? == false 
        post_content += "#{article["excerpt"]}</p><hr />"
      else
        post_content += "#{article["intro"]}</p><hr />"
      end
      puts "#{article["headline"]}"
      count += 1
    end
    break if count == 20
  end

  post_content += "<p><em>For other ways of reading us, try our <a href=\"http://www.techinasia.com/subscriptions/\" >tailored RSS feeds</a>, or find us within Flipboard.</em></p>"

    wp_articles = wp.editPost(
    post_id: 183788, 
    content: {
      post_date: DateTime.now - 1.day,
      post_content: post_content,
      post_excerpt: "Miss out on the best Asia tech news from the past seven days? Worry not, here's our roundup of the week's hottest stories."
    }
  )

end