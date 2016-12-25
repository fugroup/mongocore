module MongoCore
  class Access

    # Access levels (6)
    AL = [:all, :user, :dev, :admin, :super, :app]

    # @doc is a MongoCore::Document object
    # @keys are the keys from the model schema
    attr_accessor :keys

    # The access control class
    def initialize(model)
      @keys = model.keys
    end

    # Set the current access level
    def set(level = nil)
      set?(level) ? RequestStore.store[:access] = level : get
    end

    # Get the current access level
    def get
      RequestStore.store[:access]
    end

    # Reset the access level
    def reset
      RequestStore.store[:access] = nil
    end

    # Key readable?
    def read?(key)
      ok?(keys[key][:read]) rescue false
    end

    # Key writable?
    def write?(key)
      ok?(keys[key][:write]) rescue false
    end

    private

    # Set?
    def set?(level)
      AL.index(level) > AL.index(get || :all)
    end

    # Ok?
    def ok?(level)
      AL.index(level.to_sym) <= AL.index(get || :app)
    end

  end
end
