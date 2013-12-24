class CtwController < ApplicationController
  rescue_from XMLRPC::FaultException, with: :wrong_username_pw

	def login
	end
	def login_error
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
	def wrong_username_pw
    redirect_to :action => "login_error"
	end
end
