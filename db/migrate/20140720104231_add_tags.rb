class AddTags < ActiveRecord::Migration
  def change
  	add_column :articles, :tags, :text
  end
end
