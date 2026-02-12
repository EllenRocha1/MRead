class AddPublishYearToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :publish_year, :string
  end
end
