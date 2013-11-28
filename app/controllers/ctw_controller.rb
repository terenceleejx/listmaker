class CtwController < ApplicationController
	def login
	end
	def result
	    @username = params[:username]
	    @password = params[:password]
	end
	def complete
	    @wptitle = params[:wptitle]
	    @wpbody = params[:wpbody]
	    @username = params[:username]
	    @password = params[:password]
	end
end
