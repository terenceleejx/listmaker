class FundingController < ApplicationController
	def result
		@articles = Article.order(id: :desc).first(200)
	end
end