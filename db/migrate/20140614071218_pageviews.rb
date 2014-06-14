class Pageviews < ActiveRecord::Migration
  def change
  	add_column :articles, :pageviews, :integer
  end
end
