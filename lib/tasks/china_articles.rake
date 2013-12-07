desc "Scans Tech in Asia for China articles, and puts them in the database"
task :china_articles => :environment do
  wp = Rubypress::Client.new(
  	:host => "techinasia.com", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )

  puts "login successful"

  wpposts = wp.getPosts(
  	blog_id: "0", 
  	filter: {post_type: "post", post_status: "published", number: 20, orderby: "date", order: "DESC"}, 
  	fields: ["post_title", "terms", "post_date", "link"]
  )

  t = (Time.now - 1440).to_date

  puts "get posts successful"

  wpposts.each do |wppost|
  	if wppost["terms"].any? {|x| x["name"] == "China"} == true and 
       wppost["post_date"].to_date >= t and 
       ChinaArticle.exists?(:headline => wppost["post_title"]) == false

       response = Unirest::post "https://newsco-article-summary.p.mashape.com/summary.json", 
         headers: { 
           "X-Mashape-Authorization" => "2zPKOatW4wEiFAoWTgnmonm6G9T3WwEl"
         },
         parameters: { 
           "url" => wppost["link"]
         }
       puts "Article summarized."
       wpsummary = response.body["summary"]
       if wpsummary.nil? == true
         wpsummary = ["nil", "nil", "nil"]
       end

       ChinaArticle.create({:headline => wppost["post_title"], 
                            :summary1 => wpsummary[0], 
                            :summary2 => wpsummary[1],
                            :summary3 => wpsummary[2],
                            :date => wppost["post_date"].to_date(),
                            :url => wppost["link"]
                          })
       puts "Article saved."
    end
  end
end