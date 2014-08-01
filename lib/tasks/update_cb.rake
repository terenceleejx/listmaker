desc "Update Crunchbase with Tech in Asia articles"
task :update_cb => :environment do
  agent = Mechanize.new
  page = agent.get("http://www.crunchbase.com/login").form_with(id: "new_user") do |f|
    f.field_with(id: "user_email").value = Figaro.env.crunchbase_login
    f.field_with(id: "user_password").value = Figaro.env.crunchbase_password
  end.submit
  articles = Article.where("date >= ?", 2.days.ago.to_date)
  filtered_words = ["startups-in", "google-plus", "leaf", "marketing", "mobile", "social-media", "china", 
    "arena", "meetup", "business", "e-commerce", "ecommerce", "venture-capital", "social-media-marketing", 
    "line", "ipo", "travel", "nyse", "travel", "healthcare", "taxi", "bat", "media", "movies", "outsourcing", 
    "southeast-asia", "saas", "bitcoin", "government", "startups", "singapore", "israel", "india", "japan", 
    "china", "asia", "hong kong", "indonesia", "taiwan", "opinion", "news", "web", "gadgets", "funding", 
    "announcements", "acquisition", "acquisitions", "health", "fun", "mobile-apps", "game", "games", "smartphones", "mcommerce",
    "3g", "people", "events", "earnings", "crowdfunding", "dolphin", "lbs", "real-estate", "longform", "ad-tech",
    "internet-of-things", "ios", "angel-investor", "interview", "fashion", "advice", "philippines", "thailand",
    "lists", "censorship", "pakistan", "crowdsourcing", "malaysia", "advertising", "vietnam", "medtech", "cgi"]
  ## need to figure out ways to account for Line etc
  articles.each do |article|
    puts article["headline"]
  	if article["crunchbased"] != true && article["tags"].blank? == false
  	  article["tags"].each do |tag|
        tag_name = CGI::escape(tag["name"].gsub(" ", "-").gsub("#", "").gsub(".", "-").downcase)
        if filtered_words.include?(tag_name) == false
          puts "Evaluating #{tag["name"]}."
          sleep(4)
          begin
            response = Unirest.get "http://api.crunchbase.com/v/2/organization/#{tag_name}?user_key=#{Figaro.env.crunchbase_key}"
            if response.body["data"]["type"].blank? == false
              count = 0
              filtered_words.each do |word|
                if response.body["data"]["properties"]["permalink"] == word
                  count += 1
                end
              end
              if count == 0
                page = agent.get("http://crunchbase.com/organization/#{tag_name}")
                if page.body.include?(article["url"]) == false
                  page = agent.get("http://crunchbase.com/organization/#{tag_name}/press/new")
                  page = page.form_with(action: "/organization/#{tag_name}/press") do |f|
                    f.field_with(id: "root_base_entity_properties_url").value = article["url"]
                    f.field_with(id: "root_base_entity_properties_title").value = article["headline"]
                    if article["excerpt"].blank? == true
                      f.field_with(id: "root_base_entity_properties_summary").value = article["summary"]
                    else
                      f.field_with(id: "root_base_entity_properties_summary").value = article["excerpt"]
                    end
                  end.submit
                  page = agent.get("http://crunchbase.com/organization/#{tag_name}")
                  if page.body.include?(article["url"]) == true
                    puts "YAY! #{tag_name} link added"
                    article.crunchbased_articles.create(
                        :crunchbase_url => "http://crunchbase.com/organization/#{tag_name}"
                      )
                    article["crunchbased"] = true
                    article.save
                  end
                end
              end
            end
          rescue
            retry
          end
        end
  	  end
  	end
  end
end

# can only search by permalink. But what if permalink doesn't match company name?
# check if article exists already > see if can use crunchbase API