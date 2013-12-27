class StartupsController < ApplicationController
	def result
		@startups = Startup.order(id: :desc).first(50)
	end
end