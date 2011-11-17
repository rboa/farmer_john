require 'yaml'

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
    
    def self.run(dataset = nil)
      # TODO: change where file stored
      @@cache = YAML.load(File.open('cache_stache.yml', 'a+'))
      
      if dataset.nil?
        self.load_all_datasets
      else
        self.load_dataset(dataset)
      end
      
      File.open('cache_stache.yml', 'w') {|f| f.write(@@cache.to_yaml)}
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
    
    def self.create_seeds(model, constraints, cache_fields, *args)
      setup_defaults(model)
      setup_cache(model)
      defn = :default
      data = [{}]
      args.each do |param|
        defn = param if param.is_a?(Symbol)
        data = param if param.is_a?(Array)
        data = [param] if param.is_a?(Hash)
      end
                  
      results = []
      
      @@seeds ||= {}
      @@seeds[self.current_dataset] ||= {}
      @@seeds[self.current_dataset][model] ||= []
      data.each_with_index do |hash, index|
        values = @@defaults[self.current_dataset][model][defn].is_a?(Hash) ? @@defaults[self.current_dataset][model][defn].merge(hash) : hash
        
        cache_fields.to_a.each do |field|
          name = model.name
          @@cache[self.current_dataset][name][field] ||= []
          unless @@cache[self.current_dataset][name][field][index].nil?
            values[field] = @@cache[self.current_dataset][name][field][index]
          else
            if values[field].is_a?(Proc)
              values[field] = values[field].call
            end
            @@cache[self.current_dataset][name][field][index] = values[field]
          end
        end
        
        seed = FarmerJohn::Seed.new(model, values, constraints)
        seed.values.each do |key, value|
          next unless seed.model.defined_relationships.include?(key.to_s)
          value.flatten.each do |child_seed|
            next if child_seed.is_a?(Integer)
            remove_seed(child_seed)
          end
        end
        @@seeds[self.current_dataset][model].push(seed)
        results.push(seed)
      end
      
      return results.length == 1 ? results[0] : results
    end
    
    def self.get_index_for_seed(seed)
      return @@seeds[self.current_dataset][seed.model].index(seed)
    end
    
    private
    
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
    
    def self.setup_defaults(model)
      @@defaults ||= {}
      @@defaults[self.current_dataset] ||= {}
      @@defaults[self.current_dataset][model] ||= {}
    end
    
    def self.setup_cache(model)
      @@cache ||= {}
      @@cache[self.current_dataset] ||= {}
      @@cache[self.current_dataset][model.name] ||= {}
    end
    
    def self.seed_of_type_with_index(type, i)
      @@seeds[self.current_dataset][type][i]
    end
    
    def self.index_for_seed(seed)
      @@seeds[self.current_dataset][seed.class.name.to_sym].index seed
    end
    
    def self.remove_seed(seed)
      i = @@seeds[self.current_dataset][seed.model].index(seed)
      @@seeds[self.current_dataset][seed.model][i] = nil
    end
  end
end
