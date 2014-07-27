class CrunchbasedTable < ActiveRecord::Migration
  def change
  	remove_column :articles, :crunchbased
  	add_column :articles, :crunchbased, :boolean
  	create_table :crunchbased_articles do |t|
  		t.string :crunchbase_url
  		t.belongs_to :article
  	end
  end
end
