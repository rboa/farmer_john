module FarmerJohn
  class Planter
    def self.plant(model_name, data)
      record = model_name.new
      
      data.to_hash.each_pair do |key, value|
        next unless valid_key?(model_name, key)
        
        record.send("#{key}=", value)
      end
      
      record.save || raise(ArgumentError, "Validation Failed. Please check your seeds and try again:\n#{record.errors.inspect}")
      
      return record
    end
    
    private
    
    def self.valid_key?(model, key)
      valid = false
      
      valid = model.accepted_properties.include?(key.to_s)
      
      return valid
    end
  end
end