class ChangeStartupColumns < ActiveRecord::Migration
  def change
  	remove_column :startups, :description
  	add_column :startups, :summary1, :text
  	add_column :startups, :summary2, :text
  	add_column :startups, :summary3, :text
  end
end
