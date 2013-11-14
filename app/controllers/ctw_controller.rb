class CtwController < ApplicationController
	def login
	end
	def result
	    @username = params[:username]
	    @password = params[:password]
	end
end