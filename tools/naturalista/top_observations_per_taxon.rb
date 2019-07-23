require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Export the taxa with at least 500 observations from certain place

Usage:
  Place this file under a folder called "tools" inside rails project

  rails r tools/top_observations_per_taxon.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def data
  Rails.logger.debug 'Procesing...' if OPTS[:debug]

  # Taxa with at least 500 obs from México
  ListedTaxon.where(place_id: 6793).where('observations_count >= 500').find_each do |lt|
    next unless t = lt.taxon

    row = "#{lt.observations_count}\t#{t.name}\t#{t.rank}\t#{t.ancestry}\t#{t.id}"
    Rails.logger.debug row if OPTS[:debug]
    @file.puts row
  end
end

def creating_folder
  Rails.logger.debug "Creating folder \"#{@path}\" if doesn't exists..." if OPTS[:debug]
  FileUtils.mkpath(@path, :mode => 0755) unless File.exists?(@path)
end

def output_file
  Rails.logger.debug 'Creating output file...' if OPTS[:debug]
  @file = File.new("#{@path}/#{Time.now.strftime("%Y_%m_%d_%H-%M-%S")}_top_observations_per_taxon.csv", 'w:UTF-8')
  @file.puts "obs_count\tname\trank\tancestry\tiNat_ID"
end


start_time = Time.now

@path = 'tools/output_top_observations_per_taxon'
creating_folder
output_file
data

Rails.logger.debug "Finished after #{Time.now - start_time} sec" if OPTS[:debug]