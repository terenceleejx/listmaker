desc "Scans Tech in Asia for China articles, and puts them in the database"
task :china_articles do
  wp = Rubypress::Client.new(
  	:host => "techinasia.com", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )
  wpposts = wp.getPosts(
  	blog_id: "0", 
  	filter: {post_type: "post", post_status: "published", number: 130, orderby: "date", order: "DESC"}, 
  	fields: ["post_title", "terms", "post_date", "link"]
  )
  t = (Time.now - 604800).to_date

  response = Unirest::post "https://newsco-article-summary.p.mashape.com/summary.json", 
    headers: { 
      "X-Mashape-Authorization" => "2zPKOatW4wEiFAoWTgnmonm6G9T3WwEl"
    },
    parameters: { 
      "url" => wppost["link"]
    }

  if wpsummary.nil? == false
    wpsummary = response.body["summary"]
  else
    wpsummary = ["nil", "nil", "nil"]
  end

  wpposts.each do |wppost|
  	if wppost["terms"].any? {|x| x["name"] == "China"} == true && wppost["post_date"].to_date >= t
      ChinaArticle.create({:headline => wppost["post_title"], 
                           :summary_1 => wpsummary[0], 
                           :summary_2 => wpsummary[1],
                           :summary_3 => wpsummary[2],
                           :date => wppost["post_date"].to_date(),
                           :url => wppost["link"]
                         })
    end
  end
end