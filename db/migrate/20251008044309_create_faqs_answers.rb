class CreateFaqsAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :faqs_answers do |t|
      t.references :faq, null: false, foreign_key: true

      t.timestamps
    end
  end
end
