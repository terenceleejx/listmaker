desc "Update Crunchbase with Tech in Asia articles"
task :update_cb => :environment do
  agent = Mechanize.new
  articles = Article.where("date >= ?", 7.days.ago.to_date)
  articles.each do |article|
  	if article["crunchbased"] != true
  	  article["tags"].each do |tag|
        tag_name = tag["name"].gsub(" ", "-")
        response = Unirest.get "http://api.crunchbase.com/v/2/organization/#{tag_name}?user_key=#{Figaro.env.crunchbase_key}"
        if response.body["data"]["type"] == nil
          puts "no data found"
        else
          page = agent.get("http://crunchbase.com/organization/#{tag_name}")
          puts "#{tag_name} found"
        end
  	  end
  	end
  end
end

# needs a wordlist to filter.