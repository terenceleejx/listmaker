class FundingController < ApplicationController
	def result
		@articles = Article.order(id: :desc).first(50)
	end
end