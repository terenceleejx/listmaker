desc "Update Crunchbase with Tech in Asia articles"
task :update_cb => :environment do
  agent = Mechanize.new
  page = agent.get("http://crunchbase.com/login")
  page = page.form_with(id: "new_user") do |f|
    f.field_with(id: "user_email").value = Figaro.env.crunchbase_login
    f.field_with(id: "user_password").value = Figaro.env.crunchbase_password
  end.submit
  pp page
  articles = Article.where("date >= ?", 7.days.ago.to_date)
  filtered_words = ["startups-in", "google-plus", "leaf", "marketing", "mobile", "social-media"]
  articles.each do |article|
  	if article["crunchbased"] != true
  	  article["tags"].each do |tag|
        tag_name = tag["name"].gsub(" ", "-")
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
            puts "#{tag_name} found"
          end
        end
  	  end
  	end
  end
end

# needs a wordlist to filter.
# must search by permalink. But what if permalink doesn't match company name?