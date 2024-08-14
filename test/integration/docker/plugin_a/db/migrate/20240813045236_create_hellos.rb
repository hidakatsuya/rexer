class CreateHellos < ActiveRecord::Migration[6.1]
  def change
    create_table :hellos do |t|
      t.string :world
    end
  end
end
