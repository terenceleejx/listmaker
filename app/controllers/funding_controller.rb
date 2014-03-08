class FundingController < ApplicationController
  rescue_from XMLRPC::FaultException, with: :wrong_username_pw
	def login
	end
	def login_error
	end
	def result
	  @username = params[:username]
	  @password = params[:password]
		@articles = Article.order(id: :desc).first(200)
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