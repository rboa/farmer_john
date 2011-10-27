module FarmerJohn
  class Farmer
    def self.register_dataset(name, block)
      @@datasets ||= {}
      
      if name
        @@datasets[name.to_sym] = block
      else  # add the dataset to the unnamed datasets
        @@datasets["_#{@@datasets.length}".to_sym] = block
      end
    end
    
    def self.load_all_datasets
      @@datasets.each_pair do |name, blocks|
        self.load_dataset(name)
      end
    end
    
    def self.load_dataset(name)
      return unless dataset = @@datasets[name]
      
      @@current_dataset = name
      dataset.call
      
      Planter.plant_seeds(@@seeds[self.current_dataset])
      
      @@current_dataset = nil
    end
    
    def self.current_dataset
      @@current_dataset
    end
    
    def self.reset_datasets
      @@datasets = {}
      @@seeds = {}
      @@defaults = {}
    end
    
    def self.assign_defaults(model, name, values)
      setup_defaults(model)
      @@defaults[self.current_dataset][model][name] = values
    end
    
    def self.create_seeds(model, constraints, *args)
      setup_defaults(model)
      defn = :default
      data = {}
      args.each do |param|
        defn = param if param.is_a?(Symbol)
        data = param if param.is_a?(Array)
        data = [param] if param.is_a?(Hash)
      end
      
      @@seeds ||= {}
      @@seeds[self.current_dataset] ||= {}
      @@seeds[self.current_dataset][model] ||= []
      data.each do |hash|
        values = @@defaults[self.current_dataset][model][defn].is_a?(Hash) ? @@defaults[self.current_dataset][model][defn].merge(hash) : hash
        @@seeds[self.current_dataset][model].push(FarmerJohn::Seed.new(model, values, constraints))
      end
    end
    
    def self.get_index_for_seed(seed)
      return @@seeds[self.current_dataset][seed.model].index(seed)
    end
    
    def self.setup_defaults(model)
      @@defaults ||= {}
      @@defaults[self.current_dataset] ||= {}
      @@defaults[self.current_dataset][model] ||= {}
    end
  end
end
