# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

conn = PG::Connection.new(host: 'localhost', port: '5432', dbname: 'memo_app')

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]

  max_length_title = 20
  if title.length > max_length_title
    redirect '/error'
    return
  end

  max_length_content = 200
  if content.length > max_length_content
    redirect '/error'
    return
  end

  memos =
    conn.exec('INSERT INTO memos (title, content, timestamp)
                 VALUES ($1, $2, current_timestamp) RETURNING id', [title, content])

  redirect "/memos/#{memos[0]['id']}"
end

get '/memos' do
  @memos = conn.exec('SELECT * FROM memos ORDER BY id DESC')
  erb :index
end

get '/' do
  redirect '/memos'
end

get '/memos/:id' do |id|
  memos = conn.exec('SELECT * FROM memos WHERE id = $1', [id])
  @title = h(memos[0]['title'])
  @content = h(memos[0]['content'])
  erb :show
end

delete '/memos/:id' do |id|
  conn.exec('DELETE FROM memos WHERE id = $1', [id])
  redirect '/memos'
end

get '/memos/:id/edit' do |id|
  memos = conn.exec('SELECT * FROM memos WHERE id = $1', [id])
  @title = h(memos[0]['title'])
  @content = h(memos[0]['content'])
  erb :edit
end

patch '/memos/:id' do |id|
  title = params[:title]
  content = params[:content]
  conn.exec('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [title, content, id])
  redirect "/memos/#{id}"
end

get '/error' do
  erb :error
end
