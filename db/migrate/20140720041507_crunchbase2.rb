class Crunchbase2 < ActiveRecord::Migration
  def change
  	change_column :articles, :crunchbased, :boolean
  end
end
