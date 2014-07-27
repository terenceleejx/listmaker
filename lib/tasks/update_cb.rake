desc "Update Crunchbase with Tech in Asia articles"
task :update_cb => :environment do
  agent = Mechanize.new
  page = agent.get("http://www.crunchbase.com/login").form_with(id: "new_user") do |f|
    f.field_with(id: "user_email").value = Figaro.env.crunchbase_login
    f.field_with(id: "user_password").value = Figaro.env.crunchbase_password
  end.submit
  articles = Article.where("date >= ?", 2.days.ago.to_date)
  filtered_words = ["startups-in", "google-plus", "leaf", "marketing", "mobile", "social-media", "china", 
    "arena", "meetup", "business", "e-commerce", "venture-capital"]
  articles.each do |article|
  	if article["crunchbased"] != true
  	  article["tags"].each do |tag|
        tag_name = tag["name"].gsub(" ", "-").gsub("#", "")
        puts "#{tag_name} cleaned."
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
              page = agent.get("http://crunchbase.com/organization/#{tag_name}/press/edit")
              page = page.link_with(href: "/organization/#{tag_name}/press/new").click
              page = page.forms.first do |f|
                f.field_with(id: "root[base_entity][properties][url]").value = article["url"]
                f.field_with(id: "root[base_entity][properties][title]").value = article["headline"]
                if article["excerpt"].blank? == true
                  f.field_with(id: "root[base_entity][properties][summary]").value = article["summary"]
                else
                  f.field_with(id: "root[base_entity][properties][summary]").value = article["excerpt"]
                end
              end.submit
              puts "YAY! #{tag_name} link added"
              article["crunchbased"] = "http://crunchbase.com/organization/#{tag_name}"
              article.save
            end
          end
        end
  	  end
  	end
  end
end

# can only search by permalink. But what if permalink doesn't match company name?
# check if article exists already > see if can use crunchbase API