require File.expand_path('../helper', __FILE__)

describe "farmer_john" do
  
  describe "datamapper" do  
    before(:each) do
      FarmerJohn::Farmer.reset_datasets
      Post.all.destroy
    end

    it "should create a model if one doesn't exist" do
      dataset do
        Post.plant({:title => 'First Post', :body => 'This is a sample.'})
      end
      
      FarmerJohn::Farmer.load_all_datasets

      post = Post.first
      post.title.must_equal 'First Post'
      post.body.must_equal 'This is a sample.'
    end
    
    it 'should associate objects based on index' do
      dataset do
        Post.plant({:title => 'Parent', :comments => [0, 1]})
        
        Comment.plant([
          {:content => 'Child_1'},
          {:content => 'Child_2'}
        ])
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      post = Post.first
      post.title.must_equal 'Parent'
      post.comments.first.content.must_equal 'Child_1'
      post.comments.all[1].content.must_equal 'Child_2'
    end
    
    it 'should associate objects directly' do
      dataset do
        Post.plant({:title => 'Parent', :comments => [Comment.plant({:content => 'Child'}), Comment.plant({:content => 'Child_2'})]})
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      post = Post.first
      post.title.must_equal 'Parent'
      post.comments.first.content.must_equal 'Child'
      post.comments.all[1].content.must_equal 'Child_2'
    end
    
    it 'should constrain children properly' do
      dataset do
        Post.plant({
          :title => 'Parent',
          :comments => [Comment.constrain(:user).plant([
            {:content => 'Blah', :user => 'Bryan'},
            {:content => 'Child', :user => 'Bryan'}
          ])]
        })
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      post = Post.first
      comments = post.comments.all
      post.title.must_equal 'Parent'
      comments.length.must_equal 1
      comments[0].content.must_equal 'Child'
    end
    
    it 'should accept one constraint' do
      dataset do
        Post.constrain(:title).plant([
          {:title => 'First', :body => 'Test'},
          {:title => 'First', :body => 'Another test'}
        ])
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      p = Post.all
      post = p[0]
      
      p.length.must_equal 1
      post.title.must_equal 'First'
      post.body.must_equal 'Another test'
    end
    
    it 'should accept multiple constraints' do
      dataset do
        Post.constrain(:title, :body).plant([
          {:title => 'First', :body => 'Test'},
          {:title => 'First', :body => 'Another test'}
        ])
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      p = Post.all
      post = p[0]
      post2 = p[1]
      
      p.length.must_equal 2
      post.title.must_equal 'First'
      post.body.must_equal 'Test'
      post2.title.must_equal 'First'
      post2.body.must_equal 'Another test'
    end
    
    it 'should respond to seed' do
      dataset do
        Post.seed(
          {:title => 'First Post', :body => 'This is a sample.'}
        )
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      post = Post.first
      post.title.must_equal 'First Post'
      post.body.must_equal 'This is a sample.'
    end
    
    it 'should accept an array of hashes' do
      dataset do
        Post.plant([
          {:title => 'First Post', :body => 'This is a sample.'},
          {:title => 'Second Post', :body => 'Another sample'}
        ])
      end
      
      FarmerJohn::Farmer.load_all_datasets
    
      post = Post.all[0]
      post.title.must_equal 'First Post'
      post.body.must_equal 'This is a sample.'
      
      post2 = Post.all[1]
      post2.title.must_equal 'Second Post'
      post2.body.must_equal 'Another sample'
    end
    
    it 'should raise an exception if validation fails' do
      dataset do
        Post.plant([{:body => 'This post should fail'}])
      end
      
      lambda {FarmerJohn::Farmer.load_all_datasets}.must_raise(ArgumentError)
    end
    
    it 'should raise error if invalid constraints present' do
      dataset do
        Post.constrain(:fail).plant({:title => 'Boo'})
      end
      lambda {FarmerJohn::Farmer.load_all_datasets}.must_raise(ArgumentError)
    end
    
    it 'should allow arrays to be passed for fields' do
      dataset do
        Post.plant({:title => ['First', 'Second'], :body => 'Test'})
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      p = Post.all[0]
      p.title.must_equal 'Second'
      p.body.must_equal 'Test'
    end
    
    it 'should use proper values when constraining arrays' do
      dataset do
        Post.constrain(:title).plant([
          {:title => 'First'},
          {:title => ['First', 'Second']}
        ])
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      p = Post.all
      post = p[0]
      
      p.length.must_equal 1
      post.title.must_equal 'Second'
    end
    
    it 'should use proper values when constraining multiple versioned seeds' do
      dataset do
        Post.constrain(:title, :body).plant([
          {:title => 'First', :body => 'Foo'},
          {:title => ['First', 'Second'], :body => ['Foo', 'Boo']}
        ])
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      p = Post.all
      post = p[0]
      
      p.length.must_equal 1
      post.title.must_equal 'Second'
      post.body.must_equal 'Boo'
    end
    
    it 'should allow seed definitions' do
      dataset do
        Post.define({
          :title => 'Default'
        })

        Post.seed

        Post.define(:bryan, {
          :title => 'Bryan'
        })

        Post.seed(:bryan)
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
      p = Post.all
      post = p[0]
      post2 = p[1]
      
      p.length.must_equal 2
      post.title.must_equal 'Default'
      post2.title.must_equal 'Bryan'
    end
    
    it 'should use given values over definitions' do
      dataset do
        Post.define({
          :title => 'Default'
        })

        Post.seed([
          {:body => 'Foo'},
          {:title => 'Modified'}
        ])
      end
      
      FarmerJohn::Farmer.load_all_datasets
      
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
