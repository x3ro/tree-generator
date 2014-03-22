require 'sinatra'
require 'sinatra/multi_route'
require 'haml'
require 'sass'
require 'compass'
require './tree-generator'

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'compass.rb'))
end

EXAMPLE = <<-eof
* some
    * list
* items
* here
eof

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :"stylesheets/style", Compass.sass_engine_options
end

route :get, :post, '/' do
  @symbols = (params[:symbols] || :ascii).downcase.to_sym

  if params[:input].nil?
    @input = EXAMPLE
  else
    @input = params[:input].strip
  end

  begin
    @tree = Kramdown::Document.new(@input, :symbols => @symbols).to_tree
  rescue
    @tree = "Error parsing your input :(\n" +
      "Only markdown style continous lists are allowed."
  end

  haml :index
end
