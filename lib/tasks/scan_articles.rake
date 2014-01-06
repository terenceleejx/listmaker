desc "Scans Tech in Asia for articles, and puts them in the database"
task :scan_articles => :environment do
  wp = Rubypress::Client.new(
  	:host => "techinasia.com", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )

  puts "login successful"

  wpposts = wp.getPosts(
  	blog_id: "0", 
  	filter: {post_type: "post", post_status: "publish", number: 20, orderby: "date", order: "DESC"}, 
  	fields: ["post_title", "terms", "post_date", "link"]
  )

  puts t = (Time.now - 86400).to_date

  wpposts.each do |wppost|
  	if wppost["terms"].any? {|x| x["name"] == "China"} == true and 
       wppost["post_date"].to_date >= t and 
       ChinaArticle.exists?(:headline => wppost["post_title"]) == false

       response = Unirest::post "https://newsco-article-summary.p.mashape.com/summary.json", 
         headers: { 
           "X-Mashape-Authorization" => Figaro.env.mashape_auth
         },
         parameters: { 
           "url" => wppost["link"]
         }
       puts "China article summarized."
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
       puts "China article saved."

    # filters for keyword
    elsif wppost["terms"].any? {|x| x["name"] == "startups" or "startup"} == true and 
          wppost["post_date"].to_date >= t and 
          Startup.exists?(:headline => wppost["post_title"]) == false

          response = Unirest::post "https://newsco-article-summary.p.mashape.com/summary.json", 
            headers: { 
              "X-Mashape-Authorization" => Figaro.env.mashape_auth
            },
            parameters: { 
             "url" => wppost["link"]
            }
          puts "Startup article summarized."

          wpsummary = response.body["summary"]
          if wpsummary.nil? == true
            wpsummary = ["nil", "nil", "nil"]
          end

          # determines country of startup
          wppost["terms"].each do |term|
            if term.fetch("name").include? "startups in"
               sliced_term = term.fetch("name").gsub! "startups in ", ""
               @startup_country = sliced_term.capitalize
            end
          end

          #puts article into database
          Startup.create({:headline => wppost["post_title"], 
                          :summary1 => wpsummary[0], 
                          :summary2 => wpsummary[1],
                          :summary3 => wpsummary[2],
                          :date => wppost["post_date"].to_date(),
                          :article_url => wppost["link"],
                          :country => @startup_country
                          })
          puts "Startup article saved."
    end

  end
end