class Articles < ActiveRecord::Migration
  def change
  	create_table :china_articles do |t|
  	  t.string :headline
  	  t.string :summary1
  	  t.string :summary2
  	  t.string :summary3
  	  t.string :date
    end
  end
end
