desc "Update Crunchbase with Tech in Asia articles"
task :update_cb => :environment do
  Figaro.env.crunchbase_key
  articles = Article.where("date >= ?", 7.days.ago.to_date)
  articles.each do |article|
  	if article["crunchbased"] != true
  	  article["tags"].each do |tag|
        response = Unirest.get "http://api.crunchbase.com/v/2/organization/#{tag["name"]}?user_key=#{Figaro.env.crunchbase_key}"
        if response.body["data"]["type"] == nil
          puts "no data found"
        end
  	  end
  	end
  end
end