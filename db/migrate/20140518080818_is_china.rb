class IsChina < ActiveRecord::Migration
  def change
  	remove_column :articles, :summary2
  	remove_column :articles, :summary3
  	rename_column :articles, :summary1, :summary
  end
end
