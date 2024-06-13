class AddContentLengthFieldsToUtilities < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :content_short_length, :integer
    add_column :utilities, :content_medium_length, :integer
  end
end
