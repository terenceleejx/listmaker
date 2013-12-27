class CreateStartups < ActiveRecord::Migration
  def change
    create_table :startups do |t|
      t.string :name
      t.string :country
      t.string :article_url
      t.string :date
      t.text :description

      t.timestamps
    end
  end
end
