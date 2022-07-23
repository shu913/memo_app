# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/new' do
  erb :new
end

post '/memos' do
  memo = { 'id' => SecureRandom.uuid, 'title' => params[:title], 'content' => params[:content], 'time' => Time.now }
  File.open("./data/memos_#{memo['id']}.json", 'w') { |file| JSON.dump(memo, file) }
  redirect "/memos/#{memo['id']}"
end

get '/memos' do
  @memos = Dir.glob('./data/*').map { |file| JSON.parse(File.open(file).read) }
  @memos = @memos.sort_by { |file| file['time'] }
  erb :index
end

get '/' do
  redirect '/memos'
end

get '/memos/:id' do
  memo = File.open("./data/memos_#{params[:id]}.json") { |file| JSON.parse(file.read) }
  @title = h(memo['title'])
  @content = h(memo['content'])
  erb :show
end

get '/edit/:id' do
  memo = File.open("./data/memos_#{params[:id]}.json") { |file| JSON.parse(file.read) }
  @id = memo['id']
  @title = h(memo['title'])
  @content = h(memo['content'])
  erb :edit
end

patch '/memos/:id/edit' do
  File.open("./data/memos_#{params['id']}.json", 'w') do |file|
    memo = { 'id' => params[:id], 'title' => params[:title], 'content' => params[:content], 'time' => Time.now }
    JSON.dump(memo, file)
  end
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  File.delete("./data/memos_#{params[:id]}.json")
  redirect '/memos'
end
