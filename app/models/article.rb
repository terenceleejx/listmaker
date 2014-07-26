class Article < ActiveRecord::Base
	serialize :summary
	serialize :tags
end