class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :user_id
      t.string :title
      t.string :body
      t.string :status
      t.string :type

      t.timestamps null: false
    end
  end
end
