require File.expand_path('../helper', __FILE__)

describe "farmer_john" do
  
  describe "datamapper" do  
    before(:each) do
      Post.all.destroy
    end

    it "should create a model if one doesn't exist" do
      Post.plant(
        {:title => 'First Post', :body => 'This is a sample.'}
      )

      post = Post.first
      post.title.must_equal 'First Post'
      post.body.must_equal 'This is a sample.'
    end
    
    it 'should respond to seed' do
      Post.seed(
        {:title => 'First Post', :body => 'This is a sample.'}
      )
      
      post = Post.first
      post.title.must_equal 'First Post'
      post.body.must_equal 'This is a sample.'
    end
    
    it 'should accept an array of hashes' do
      Post.plant([
        {:title => 'First Post', :body => 'This is a sample.'},
        {:title => 'Second Post', :body => 'Another sample'}
      ])
    
      post = Post.all[0]
      post.title.must_equal 'First Post'
      post.body.must_equal 'This is a sample.'
      
      post2 = Post.all[1]
      post2.title.must_equal 'Second Post'
      post2.body.must_equal 'Another sample'
    end
    
    it 'should raise an exception if validation fails' do
      lambda { Post.plant([{:body => 'This post should fail'}]) }.must_raise(ArgumentError)
    end
  end
end
