class AddColumnsToArticle < ActiveRecord::Migration
  def change
  	add_column :articles, :excerpt, :text
  	add_column :articles, :intro, :text
  end
end
