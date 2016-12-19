module MongoCore
  class Query

    attr_accessor :db, :model, :collection, :colname, :query, :options

    def initialize(m, q = {}, o = {})
      # Support find passing a ID
      q = {:_id => oid(q)} if q.is_a?(String) or q.is_a?(BSON::ObjectId)

      # Mongodb wants _id as BSON::ObjectId, not id as String
      q[:_id] = oid(q.delete(:id)) if q[:id]

      # Storing model and db
      @model = m
      @db = MongoCore.db

      # The model name is singular, the collection name is plural
      @colname = "#{m.to_s.downcase}s".to_sym

      # Storing the Mongo::Collection object
      @collection = @db[@colname]

      # Storing query and options
      @query = q
      @options = o
    end

    # Convert string id into a BSON::ObjectId
    # Pass nothing or nil to get a new ObjectId
    def oid(id = nil)
      return id if id.is_a?(BSON::ObjectId)
      return BSON::ObjectId.new if !id
      BSON::ObjectId.from_string(id) rescue id
    end

    # Find. Returns a MongoCore::Query
    def find(q = {}, o = {})
      MongoCore::Query.new(@model, q, @options.merge(o))
    end

    # Count. Returns the number of documents as an integer
    def count
      collection.find(@query, @options).count
    end

    # Update
    def update(a)
      collection.update_one(@query, {'$set' => a}, :upsert => true)
    end

    # Delete
    def delete
      collection.delete_one(@query)
    end

    # Return first document
    def first
      doc = collection.find(@query, @options).first
      doc ? @model.new(doc.to_hash) : nil
    end

    # Return all documents
    def all
      docs = collection.find(@query, @options).to_a
      docs.map{|doc| doc ? @model.new(doc.to_hash) : nil}.compact
    end

  end
end
