desc "Scans Tech in Asia for articles, and puts them in the database"
task :scan_articles => :environment do
  wp = Rubypress::Client.new(
  	:host => "techinasia.com", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )

  puts "login successful"

  t = (Time.now - 604800).to_date

  wp_articles = wp.getPosts(
    blog_id: "0", 
    filter: {post_type: "post", post_status: "publish", number: 100, orderby: "date", order: "DESC"}, 
    fields: ["post_title", "terms", "post_date", "link"]
  )

  wp_articles.each do |wp_article|
    if wp_article["post_date"].to_date >= t && Article.exists?(:headline => wp_article["post_title"]) == false
      response = Unirest::post "https://newsco-article-summary.p.mashape.com/summary.json", 
        headers: { 
          "X-Mashape-Authorization" => Figaro.env.mashape_auth
        },
        parameters: { 
          "url" => wp_article["link"]
        }

      puts "Articles summarized."

      wpsummary = response.body["summary"]

      if wpsummary.nil? == true
        wpsummary = ["nil", "nil", "nil"]
      end

      # determines country of startup type of article
      wp_article["terms"].each do |term|
        @is_startup = false
        if term.fetch("name").include? "startups in"
          sliced_term = term.fetch("name").gsub!("startups in ", "").gsub("the ", "")
          @startup_country = sliced_term.capitalize
          @is_startup = true
        else
          @startup_country = "COUNTRY"
        end
        break if @is_startup == true
      end

      wp_article["terms"].each do |term|
        @is_funding = false
        if term.fetch("name").include? "funding"
          @is_funding = true
        end
        break if @is_funding == true
      end

      Article.create({
          :headline => wp_article["post_title"],
          :summary1 => wpsummary[0], 
          :summary2 => wpsummary[1],
          :summary3 => wpsummary[2],
          :date => wp_article["post_date"].to_date(),
          :url => wp_article["link"],
          :country => @startup_country,
          :funding => @is_funding,
          :startup => @is_startup
        })
    end
  end

  puts "first scanning completed"

  wp_articles.each do |wp_article|
  	if wp_article["terms"].any? {|x| x["name"] == "China"} == true and 
       wp_article["post_date"].to_date >= t and 
       ChinaArticle.exists?(:headline => wp_article["post_title"]) == false

       response = Unirest::post "https://newsco-article-summary.p.mashape.com/summary.json", 
         headers: { 
           "X-Mashape-Authorization" => Figaro.env.mashape_auth
         },
         parameters: { 
           "url" => wp_article["link"]
         }
       puts "China article summarized."
       wpsummary = response.body["summary"]
       if wpsummary.nil? == true
         wpsummary = ["nil", "nil", "nil"]
       end

       ChinaArticle.create({:headline => wp_article["post_title"], 
                            :summary1 => wpsummary[0], 
                            :summary2 => wpsummary[1],
                            :summary3 => wpsummary[2],
                            :date => wp_article["post_date"].to_date(),
                            :url => wp_article["link"]
                          })
       puts "China article saved."
    end
  end
end