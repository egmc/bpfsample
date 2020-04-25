require 'memcached'
cache = Memcached.new("localhost:11211")

key_prefix = 'rubysample_'

(1..100).each do |i|
  key =  key_prefix + i.to_s
  cache.set key, i.to_s , 100
  cache.get key
  sleep 1
end
