require File.expand_path('../helper', __FILE__)

describe "dataset" do
  before(:each) do
    FarmerJohn::Farmer.reset_datasets
    Post.all.destroy
    # Post.define({})
  end

  it "should create a dataset" do
    dataset do
      Post.plant({:title => 'First Post', :body => 'This is a sample.'})
    end
    
    FarmerJohn::Farmer.load_all_datasets
    Post.count.must_equal 1
    
    FarmerJohn::Farmer.load_unnamed_datasets
    Post.count.must_equal 2
  end
  
  it "should create a named dataset" do
    dataset :first do
      Post.plant({:title => 'First Post', :body => 'This is a sample.'})
    end
    
    FarmerJohn::Farmer.load_unnamed_datasets
    Post.count.must_equal 0
    
    FarmerJohn::Farmer.load_dataset(:first)
    Post.count.must_equal 1
  end
end
