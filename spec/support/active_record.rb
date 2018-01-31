# frozen_string_literal: true

# Use an in memory sqlite database
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Base.connection.create_table 'ci_sessions', primary_key: 'session_id', id: :string do |t|
  t.string 'ip_address', null: false
  t.string 'user_agent', null: false
  t.integer 'last_activity', null: false, unsigned: true
  t.text 'user_data'
end
