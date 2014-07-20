class Crunchbase < ActiveRecord::Migration
  def change
  	add_column :articles, :crunchbased, :boolean, :default => false
  end
end
