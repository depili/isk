class CreateSlideTemplates < ActiveRecord::Migration
  def change
    create_table :slide_templates do |t|
      t.string :name
      t.references :event, index: true
      t.timestamps
    end
  end
end
