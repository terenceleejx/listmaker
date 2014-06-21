class HottestController < ApplicationController
	def result
		@articles = Article.order(pageviews: :desc).order(date: :desc)
	end
end