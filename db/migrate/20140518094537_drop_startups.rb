class DropStartups < ActiveRecord::Migration
  def change
  	drop_table :startups
  end
end
