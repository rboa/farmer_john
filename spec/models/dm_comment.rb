class Comment
  include DataMapper::Resource
  
  property :id, Serial
  property :content, String, :required => true
  property :user, String
  
  belongs_to :post
end