module Bramble
  # eg, Redis uses strings only, so use this module to freeze and thaw values from storage
  module Serialize
    # prepare an object for storage
    def self.dump(obj)
      Marshal.dump(obj)
    end

    # reload an object from storage
    def self.load(stored_obj)
      case stored_obj
      when Array
        stored_obj.map { |obj| load(obj) }
      when Hash
        stored_obj.inject({}) do |memo, (k, v)|
          memo[load(k)] = load(v)
          memo
        end
      else
        Marshal.load(stored_obj)
      end
    end
  end
end
