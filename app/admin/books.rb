ActiveAdmin.register Book do
  permit_params :utility_id, :user_id, :genre, :author, :image, :title, :publisher, :year

  index do
    selectable_column
    id_column
    column :utility_id
    column :user_id
    column :genre
    column :author
    column :image
    column :title
    column :publisher
    column :year
    column :created_at
    column :updated_at
    actions
  end

  filter :utility_id
  filter :user_id
  filter :genre
  filter :author
  filter :title
  filter :publisher
  filter :year
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :utility
      f.input :user, as: :select, collection: User.all.map { |u| [u.full_name, u.id] }
      f.input :genre
      f.input :author
      f.input :image
      f.input :title
      f.input :publisher
      f.input :year
    end
    f.actions
  end

  show do
    attributes_table do
      row :utility
      row :user
      row :genre
      row :author
      row :image
      row :title
      row :publisher
      row :year
      row :created_at
      row :updated_at
    end
  end
end
