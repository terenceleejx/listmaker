class CtwController < ApplicationController
	def login
	end
	def result
	    @username = params[:username]
	    @password = params[:password]
	end
	def complete
	end
end
