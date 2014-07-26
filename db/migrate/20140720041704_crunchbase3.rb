class Crunchbase3 < ActiveRecord::Migration
  def change
  	remove_column :articles, :crunchbased
  	add_column :articles, :crunchbased, :boolean
  end
end
