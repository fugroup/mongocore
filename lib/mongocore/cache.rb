module Mongocore

  # # # # # # # #
  # The Cache class keeps track of cache entries.
  #
  # Every query is cached, used the state as the cache key. This is a
  # very aggressive strategy, where arrays won't get updated on update or delete.
  #

  class Cache

    # Accessors
    attr_accessor :query, :cache, :key, :type

    # Init
    def initialize(q)
      @query = q
      @cache = (RequestStore[:cache] ||= {})
      @key = Digest::MD5.hexdigest(@query.key)
    end

    # Get the cache key
    def get(t)
      @cache[t = key + t.to_s].tap{|d| stat(d, t) if Mongocore.debug}
    end

    # Set the cache key
    def set(t, v = nil)
      t = key + t.to_s; v ? cache[t] = v : cache.delete(t)
    end

    private

    # Stats for debug and cache
    def stat(d, t)
      puts('Cache ' + (d ? 'Hit!' : 'Miss') + ': ' + t)
      RequestStore[d ? :h : :m] = (RequestStore[d ? :h : :m] || 0) + 1
    end

  end
end
