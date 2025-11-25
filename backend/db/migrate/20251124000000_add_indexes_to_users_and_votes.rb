class AddIndexesToUsersAndVotes < ActiveRecord::Migration[8.1]
  def change
    # Add unique index on users.email for faster uniqueness checks
    add_index :users, :email, unique: true, if_not_exists: true

    # Add index on votes.country_code for faster GROUP BY and WHERE queries
    add_index :votes, :country_code, if_not_exists: true

    # Add unique index on votes.user_id to enforce uniqueness at DB level
    add_index :votes, :user_id, unique: true, if_not_exists: true
  end
end
