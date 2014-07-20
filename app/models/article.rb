class Article < ActiveRecord::Base
	serialize :summary, :tags
end