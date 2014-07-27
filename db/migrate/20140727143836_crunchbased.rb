class Crunchbased < ActiveRecord::Migration
  def change
  	change_column :articles, :crunchbased, :string
  end
end
