desc "Update Crunchbase with Tech in Asia articles"
task :update_cb => :environment do
  agent = Mechanize.new
  page = agent.get("http://www.crunchbase.com/login").form_with(id: "new_user") do |f|
    f.field_with(id: "user_email").value = Figaro.env.crunchbase_login
    f.field_with(id: "user_password").value = Figaro.env.crunchbase_password
  end.submit
  articles = Article.all#where("date >= ?", 2.days.ago.to_date)
  filtered_words = ["startups-in", "google-plus", "leaf", "marketing", "mobile", "social-media", "china", 
    "arena", "meetup", "business", "e-commerce", "venture-capital", "social-media-marketing", "line"]
  ## need to figure out ways to account for Line etc
  articles.each do |article|
  	if article["crunchbased"] != true
  	  article["tags"].each do |tag|
        puts "Evaluating #{tag["name"]}."
        tag_name = tag["name"].gsub(" ", "-").gsub("#", "")
        response = Unirest.get "http://api.crunchbase.com/v/2/organization/#{tag_name}?user_key=#{Figaro.env.crunchbase_key}"
        if response.body["data"]["type"] != nil
          count = 0
          filtered_words.each do |word|
            if response.body["data"]["properties"]["permalink"] == word
              count += 1
            end
          end
          if count == 0
            page = agent.get("http://crunchbase.com/organization/#{tag_name}")
            if page.parser.include?(article["url"]) == false
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
              if page.parser.include?(article["url"]) == true
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
  	  end
  	end
  end
end

# can only search by permalink. But what if permalink doesn't match company name?
# check if article exists already > see if can use crunchbase API