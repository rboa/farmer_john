require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'dm-sqlite-adapter'

# setup repository
DataMapper.setup(:default, "sqlite3::memory:")

class Post
  include DataMapper::Resource

  property :id,     Serial
  property :title,  String, :required => true
  property :body,   String
end

DataMapper.auto_migrate!