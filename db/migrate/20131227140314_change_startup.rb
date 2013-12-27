class ChangeStartup < ActiveRecord::Migration
  def change
  	rename_column :startups, :name, :headline
  end
end
