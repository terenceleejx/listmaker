class DefaultSumamry < ActiveRecord::Migration
  def change
  	change_column :articles, :summary, :text, :default => "['nil']"
  end
end
