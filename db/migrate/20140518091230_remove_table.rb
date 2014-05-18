class RemoveTable < ActiveRecord::Migration
  def change
  	drop_table :china_articles
  end
end
