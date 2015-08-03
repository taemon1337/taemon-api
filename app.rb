# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

# Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
# set, when working locally this line will fall back to using SQLite in the
# current directory.
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/db/development.sqlite")

require './models/todo.rb'

# Finalize the DataMapper models.
DataMapper.finalize

# Tell DataMapper to update the database according to the definitions above.
DataMapper.auto_upgrade!

configure do

end

get '/' do
  send_file './public/index.html'
end

# Route to show all Things, ordered like a blog
get '/todos' do
  content_type :json
  @todos = Todo.all(:order => :created_at.desc)

  @todos.to_json
end

# CREATE: Route to create a new Thing
post '/todos' do
  content_type :json

  @todo = Todo.new(params[:todo])

  if @todo.save
    @todo.to_json
  else
    halt 500
  end
end

# READ: Route to show a specific Thing based on its `id`
get '/todos/:id' do
  content_type :json
  @todo = Todo.get(params[:id].to_i)

  if @todo
    @todo.to_json
  else
    halt 404
  end
end

# UPDATE: Route to update a Thing
put '/todos/:id' do
  content_type :json

  @todo = Todo.get(params[:id].to_i)
  @todo.update(params[:todo])

  if @todo.save
    @todo.to_json
  else
    halt 500
  end
end

# DELETE: Route to delete a Thing
delete '/todo/:id/delete' do
  content_type :json
  @todo = Todo.get(params[:id].to_i)

  if @todo.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end
