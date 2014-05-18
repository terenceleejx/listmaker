class IsChina2 < ActiveRecord::Migration
  def change
  	add_column :articles, :china, :boolean
  end
end
