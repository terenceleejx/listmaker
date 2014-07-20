desc "Update Crunchbase with Tech in Asia articles"
task :update_cb => :environment do
	require 'crunchbase'
	Crunchbase::API.key = Figaro.env.crunchbase_key
  articles = Article.where("date >= ?", 7.days.ago.to_date)
  articles.each do |article|
  	if article["crunchbased"] != true
  	 article["terms"].each do |term|

  	 end
  	end
  end
end