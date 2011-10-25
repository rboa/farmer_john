module FarmerJohn
  class Farmer
    def self.register_dataset(name, block)
      @@datasets ||= {}
      
      if name
        @@datasets[name.to_sym] = [block]
      else  # add the dataset to the unnamed datasets
        @@datasets[:_] ||= []
        @@datasets[:_] << block
      end
    end
    
    def self.load_all_datasets
      @@datasets.each_pair do |name, blocks|
        self.load_dataset(name)
      end
    end
    
    def self.load_unnamed_datasets
      self.load_dataset(:_)
    end
    
    def self.load_dataset(name)
      return unless datasets = @@datasets[name]
      
      @@current_dataset = name
      datasets.each { |d| d.call }
      @@current_dataset = nil
    end
    
    def self.current_dataset
      @@current_dataset
    end
    
    def self.reset_datasets
      @@datasets = {}
    end
  end
end
