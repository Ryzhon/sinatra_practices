# frozen_string_literal: true

require 'sinatra'
require 'cgi'
require 'dotenv/load'
require_relative 'db_connection'

helpers do
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

configure do
  db_connection = DBConnection.conn
  result = db_connection.exec("SELECT * FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'memos'")
  db_connection.exec('CREATE TABLE memos (id SERIAL PRIMARY KEY, title VARCHAR(255), content TEXT)') if result.values.empty?
end

def load_memos
  memos = {}
  result = DBConnection.conn.exec('SELECT * FROM memos ORDER BY id DESC')
  result.each do |row|
    id = row['id']
    title = row['title'] || ''
    content = row['content'] || ''
    memos[id] = { title:, content: }
  end
  memos
end

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  DBConnection.conn.exec_params('INSERT INTO memos (title, content) VALUES ($1, $2)', [params[:title], params[:content]])
  redirect to('/memos')
end

get '/memos/:id' do
  result = DBConnection.conn.exec_params('SELECT * FROM memos WHERE id = $1 LIMIT 1', [params[:id]])
  @memo = result.map { |row| row.transform_keys(&:to_sym) }.first

  erb :show
end

get '/memos/:id/edit' do
  result = DBConnection.conn.exec_params('SELECT * FROM memos WHERE id = $1 LIMIT 1', [params[:id]])
  @memo = result.map { |row| row.transform_keys(&:to_sym) }.first
  erb :edit
end

patch '/memos/:id' do
  DBConnection.conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [params[:title], params[:content], params[:id].to_i])
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  DBConnection.conn.exec_params('DELETE FROM memos WHERE id = $1', [params[:id].to_i])
  redirect to('/memos')
end
