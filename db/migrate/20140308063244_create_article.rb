class CreateArticle < ActiveRecord::Migration
  def change
    create_table :articles do |t|
    	t.string "headline"
    	t.string "url"
    	t.string "date"
      t.text   "summary1"
      t.text   "summary2"
      t.text   "summary3"
      t.string "country"
      t.boolean "funding"
      t.boolean "startup"
      t.string "techlist_url"
    end
  end
end
