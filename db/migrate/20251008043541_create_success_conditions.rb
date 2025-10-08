class CreateSuccessConditions < ActiveRecord::Migration[8.0]
  def change
    create_table :success_conditions do |t|
      t.references :tactic, null: false, foreign_key: true
      t.string :body

      t.timestamps
    end
  end
end
