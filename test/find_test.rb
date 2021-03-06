test 'Find'

# Query
@query = Model.find
is @query, :a? => Mongocore::Query

# Count
is Model.count, :a? => Integer
is Model.count, :gt => 0

# First
@model = @query.first
is @model, :a? => Model
is @model.duration, :gt => 0

# All
@models = @query.all

is @models, :a? => Array
is @models.size, :gt => 0

# Find
@models = Model.find(:duration => 60).all
is @models, :a? => Array

# Array
model = Model.new
model.save

model2 = Model.find(:_id => {:$in => [model._id]}).first
is model2.id, model.id

model2 = Model.find(:id => {:$in => [model._id]}).first
is model2.id, model.id

model2 = Model.find(:_id => {:$in => [model.id]}).first
is model2.id, model.id

model2 = Model.find(:$or => [{:_id => model.id}, {:duration => 1231234}]).first
is model2.id, model.id

model2 = Model.find(:$or => [{:id => model.id}, {:duration => 1231234}]).first
is model2.id, model.id
