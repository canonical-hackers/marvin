class Storage
  require 'yaml'
  
  attr_accessor :filename, :data

  def initialize(file) 
    @filename = file 
    @data = YAML::load(File.open(@filename)) if File::exist?(@filename) 
    @data = Hash.new unless @data 
  end

  def save
    File.open(@filename, 'w') do |file| 
      YAML::dump(@data, file) 
    end
  end 
end 

