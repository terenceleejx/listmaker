class CtwController < ApplicationController
	def login
	end
	def result
	    @username = params[:username]
	    @password = params[:password]
	    @china_articles = ChinaArticle.order(id: :desc).first(25)
	end
	def complete
	    @wptitle = params[:wptitle]
	    @wpbody = params[:wpbody]
	    @username = params[:username]
	    @password = params[:password]
	end
end
