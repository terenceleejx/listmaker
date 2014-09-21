desc "Scans Tech in Asia for articles, and puts them in the database"
task :scan_articles => :environment do
  wp = Rubypress::Client.new(
  	:host => "www.techinasia.com/core", 
  	:username => Figaro.env.techinasia_username, 
  	:password => Figaro.env.techinasia_password
  )

  puts "login successful"

  t = (Time.now - 1072800).to_date

  wp_articles = wp.getPosts(
    blog_id: "0", 
    filter: {post_type: "post", post_status: "publish", number: 100, orderby: "date", order: "DESC"}, 
    fields: ["post_title", "terms", "post_date", "link", "post_excerpt", "post_content"]
  )

  puts "Wordpress posts retrieved"

  wp_articles.each do |wp_article|
    if wp_article["post_date"].to_date >= t && Article.exists?(:url => wp_article["link"]) == false
      summary_url = "https://aylien-text.p.mashape.com/summarize?url=" + CGI::escape(wp_article["link"])
      response = Unirest::get summary_url, 
        headers: { 
          "X-Mashape-Authorization" => Figaro.env.mashape_auth
        }

      puts "Articles summarized."

      puts wpsummary = response.body["sentences"]

      if wpsummary.nil? == true
        wpsummary = ["Summarization failed."]
      end

      @intro_array = CGI.unescapeHTML(ActionView::Base.full_sanitizer.sanitize(wp_article["post_content"].gsub(/\n/, ' '))).split('. ')
      @intro = @intro_array[0].strip + '. ' + @intro_array[1] + '.'

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

      wp_article["terms"].each do |term|
        @is_china = false
        if term.fetch("name").include? "China"
          @is_china = true
        end
        break if @is_china == true
      end

      Article.create({
          :headline => wp_article["post_title"],
          :summary => wpsummary,
          :date => wp_article["post_date"].to_date(),
          :url => wp_article["link"],
          :country => @startup_country,
          :funding => @is_funding,
          :startup => @is_startup,
          :china => @is_china,
          :excerpt => wp_article["post_excerpt"],
          :intro => @intro,
          :tags => wp_article["terms"]
        })
    end
  end

  puts "Scanning completed"

end