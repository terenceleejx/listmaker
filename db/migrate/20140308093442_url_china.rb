class UrlChina < ActiveRecord::Migration
  def change
  	add_column :china_articles, :url, :string
  end
end
