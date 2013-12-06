class ChangeArticleString < ActiveRecord::Migration
  def change
  	change_column :china_articles, :summary1, :text
  	change_column :china_articles, :summary2, :text
  	change_column :china_articles, :summary3, :text
  end
end
