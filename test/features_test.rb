test 'Features'

m = Model.new
m.duration = 59
m.save

m2 = Model.new
n = BSON::ObjectId.new
m2.id = n
is m2._id, :a? => BSON::ObjectId
is m2.id, n.to_s
m2.id = BSON::ObjectId.new
is m2._id, :a? => BSON::ObjectId
is m2.id, :a? => String
is m2.id, m2._id.to_s

is m.duration, 59

p = Parent.new(:house => 'Nice')
p.save
p = p.reload
is p.house, 'Nice'

m.parent = p
m.save

x = Model.last
is x._id, :a? => BSON::ObjectId

x.parent = p
x.save

d = p.models.all
f = p.models.first
l = p.models.last

test 'find'

@query = Model.find
is @query, :a? => Mongocore::Query

m = @query.all
x = @query.featured.all
c = @query.count
l = @query.last
f = @query.first

m = Model.find.all

m = Model.find(:house => {:$ne => 'Fluff', :$eq => 'Nice'}).last
is m, :eq => nil

test 'sort'

p = Parent.first
m = Model.find({:duration => {:$gt => 40}}, :sort => {:duration => -1}).all
is m, :a? => Array

is Model.find(:duration => {:$gt => 50}).count, :gt => 1
m = Model.find(:duration => {:$gt => 50}).sort(:duration => -1).first
a = Model.find(:duration => {:$gt => 50}).sort(:duration => 1).first

is m._id.to_s == a._id.to_s, :eq => false

m = Model.find.sort(:duration => 1).limit(5).all
is m.size, 5

test 'limit'

p = Parent.limit(1).last
is p, :a? => Parent

m = Model.find({}, :sort => {:goal => 1}, :limit => 2).all
is m.size, 2

m = Model.sort(:goal => 1, :duration => -1).limit(10).all
is m.size, 10

test 'first'

id = Model.first._id
m = Model.find(:_id => id).first
is m._id.to_s, :eq => id.to_s

m = Model.find(id).first
is m._id.to_s, :eq => id.to_s

m = Model.find(id.to_s).first
is m._id.to_s, :eq => id.to_s

m = Model.find(:goal => {:$gt => 0}).first
is m, :a? => Model

test 'last'

m = Model.last
is m, :a? => Model

p = Parent.new
m.parent = p
is m.save
is p.save

pl = Parent.last
is pl.id, p.id

mp = pl.models.last
is mp, :a? => Model

m2 = Model.last(m.id)
is m, :a? => Model
is m.id, m2.id

test 'count'

c = Model.count
is c, :gt => 0

p = Parent.first
c = Model.featured.count

is c, :gt => 0

m = Model.last
c = Model.count(m.id)

is c, :gt => 0

test 'changes'
m = Model.new
is m.duration, 60

m.duration = 33
is m.changed?, :eq => true
is m.duration_changed?, :eq => true
is m.duration_was, 60
is m.changes[:duration], :a? => Array
is m.changes[:duration][0], 60
is m.changes[:duration][1], 33
is m.changes.any?, :eq => true
is m.saved?, :eq => false
is m.unsaved?, :eq => true
m.save
is m.saved?, :eq => true
is m.unsaved?, :eq => false
is m.valid?, :eq => true
m.duration = -1
is m.valid?, :eq => false
is m.errors[:duration].first, :a? => String
m.errors.delete(:duration)
m.duration = -1
m.save(:validate => true)
is m.valid?, :eq => false
is m.errors[:duration].first, :a? => String
m.errors.delete(:duration)
m.duration = 33

m = Model.new
is m.changes, {}
is m.duration, 60
is m.duration_was, 60

m.duration = 50
is m.duration, 50
is m.changes[:duration][0], 60
is m.changes[:duration][1], 50
is m.duration_changed?
is m.duration_was, 60

test 'update'

m.update(:duration => 20)
is m.duration, 20
m = m.reload
is m.duration, 20

test 'delete'

m = Model.last
id = m._id
m.delete
m = Model.find(id).first
is m, :eq => nil

test 'many'
p = Parent.new
is p.save

m = Model.new
m.parent = p
is m.save

q = p.models.all
is q.first, :a? => Model

m = p.models.first
is q.first, :a? => Model

m = p.models.last
is q.first, :a? => Model

test 'scopes'

q = Model.featured.all
is q.first, :a? => Model

model = Model.last
model.goal = 10
is model.save

q = Model.featured.nested.all
is q.first, :a? => Model

m = Model.featured.first
is m, :a? => Model

test 'aliases'

is Model.where
is Model.where.where
model = Model.first
is model.new_record?, false
is model.persisted?, true
