# frozen_string_literal: true

require 'sinatra'
require 'csv'
require 'securerandom'
require 'cgi'

helpers do
  def h(text)
    CGI.escapeHTML(text.to_s)
  end
end

FILE_PATH = './memos.csv'

def load_memos
  return {} unless File.exist?(FILE_PATH)

  memos = {}
  CSV.foreach(FILE_PATH, headers: true, header_converters: :symbol) do |row|
    next if row.to_h.empty?

    id = row[:id]
    title = row[:title] || ''
    content = row[:content] || ''
    memos[id] = { title:, content: }
  end
  memos
end

def save_memos(memos)
  CSV.open(FILE_PATH, 'wb') do |csv|
    csv << %w[id title content]
    memos.each do |id, memo|
      csv << [id, memo[:title], memo[:content]]
    end
  end
end

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  @memo = load_memos[params[:id]]
  erb :show
end

post '/memos' do
  memos = load_memos
  id = SecureRandom.uuid
  memos[id] = { title: params[:title], content: params[:content] }
  save_memos(memos)
  redirect to('/memos')
end

get '/memos/:id/edit' do
  @memo = load_memos[params[:id]]
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos
  memos[params[:id]][:title] = params[:title]
  memos[params[:id]][:content] = params[:content]
  save_memos(memos)
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  memos = load_memos
  memos.delete(params[:id])
  save_memos(memos)
  redirect to('/memos')
end
