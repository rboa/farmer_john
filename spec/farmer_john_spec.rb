require File.expand_path('../helper', __FILE__)

describe "farmer_john" do
  
  describe "datamapper" do  
    before(:each) do
      Post.all.destroy
      Post.define({})
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
    
    it 'should accept one constraint' do
      Post.constrain(:title).plant([
        {:title => 'First', :body => 'Test'},
        {:title => 'First', :body => 'Another test'}
      ])
      
      p = Post.all
      post = p[0]
      
      p.length.must_equal 1
      post.title.must_equal 'First'
      post.body.must_equal 'Another test'
    end
    
    it 'should accept multiple constraints' do
      Post.constrain(:title, :body).plant([
        {:title => 'First', :body => 'Test'},
        {:title => 'First', :body => 'Another test'}
      ])
      
      p = Post.all
      post = p[0]
      post2 = p[1]
      
      p.length.must_equal 2
      post.title.must_equal 'First'
      post.body.must_equal 'Test'
      post2.title.must_equal 'First'
      post2.body.must_equal 'Another test'
    end
    
    it 'should raise error if invalid constraints present' do
      lambda { Post.constrain(:fail) }.must_raise(ArgumentError)
    end
    
    it 'should allow arrays to be passed for fields' do
      Post.plant({:title => ['First', 'Second'], :body => 'Test'})
      
      p = Post.all[0]
      p.title.must_equal 'Second'
      p.body.must_equal 'Test'
    end
    
    it 'should use proper values when constraining arrays' do
      Post.constrain(:title).plant([
        {:title => 'First'},
        {:title => ['First', 'Second']}
      ])
      
      p = Post.all
      post = p[0]
      
      p.length.must_equal 1
      post.title.must_equal 'Second'
    end
    
    it 'should allow seed definitions' do
      Post.define({
        :title => 'Default'
      })

      Post.seed

      Post.define(:bryan, {
        :title => 'Bryan'
      })

      Post.seed(:bryan)
      
      p = Post.all
      post = p[0]
      post2 = p[1]
      
      p.length.must_equal 2
      post.title.must_equal 'Default'
      post2.title.must_equal 'Bryan'
    end
    
    it 'should use given values over definitions' do
      Post.define({
        :title => 'Default'
      })

      Post.seed([
        {:body => 'Foo'},
        {:title => 'Modified'}
      ])
      
      p = Post.all
      post = p[0]
      post2 = p[1]
      
      p.length.must_equal 2
      post.title.must_equal 'Default'
      post.body.must_equal 'Foo'
      post2.title.must_equal 'Modified'
    end
  end
end
