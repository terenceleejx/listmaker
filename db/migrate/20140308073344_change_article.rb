class ChangeArticle < ActiveRecord::Migration
  def change
  	remove_column :articles, :techlist_url
  	remove_column :articles, :date
  	add_column :articles, :date, :date
  end
end
