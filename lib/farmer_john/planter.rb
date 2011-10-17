module FarmerJohn
  class Planter
    def self.plant(model_name, data)
      record = model_name.new(data)
      record.save || raise(ArgumentError, "Validation Failed. Please check your seeds and try again:\n#{record.errors.inspect}")
    end
  end
end