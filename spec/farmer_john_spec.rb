require 'minitest/autorun'

require File.join( File.dirname(__FILE__), '..', 'lib', 'farmer_john', "dm_extension")
require File.join( File.dirname(__FILE__), '..', 'lib', 'farmer_john', "planter")

require 'rubygems'

describe "farmer_john" do
  
  describe "datamapper" do  
    before(:each) do
      load File.join( File.dirname(__FILE__), "models", "dm_post.rb")
    end

    it "should create a model if one doesn't exist" do
      Post.plant([
        {:title => 'First Post', :body => 'This is a sample.'}
      ])

      post = Post.get(1)
      post.title.must_equal 'First Post'
      post.body.must_equal 'This is a sample.'
    end
    
    it 'should raise an exception if validation fails' do
      lambda { Post.plant([{:body => 'This post should fail'}]) }.must_raise(ArgumentError)
    end
  end
end