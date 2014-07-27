class Article < ActiveRecord::Base
	serialize :summary
	serialize :tags
	has_many :crunchbased_articles
end