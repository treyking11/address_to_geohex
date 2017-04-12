require 'csv'
require 'geo_hex/coverage'
class GeocoderController < ApplicationController

  def index
  end

  def create
    process_tempfile params['locations'].tempfile, params['locations'].original_filename
  end
  
  private
  
    def process_tempfile temp_file, filename
      gh_level    = 9
      results_csv = []
      geohexes    = []
      CSV.foreach(temp_file, headers: true) do |row|
        query                             = [row['Address'], row['City'], row['State'], row['Zip']].join(', ')
        result                            = Geocoder.search(query)
        row['latitude'], row['longitude'] = result.first.coordinates
                
        coverage                          = GeoHex::Coverage.new(row['latitude'], row['longitude'])
        meters                            = row['Radius'].to_f * 1609.34
        logger.info { "Radius in miles #{row['Radius']}, meters #{meters}" }
        geohexes << coverage.within( meters ).collect(&:code).uniq
        
        results_csv << row.to_hash
      end
    
      CSV.open(File.join(Rails.root, "public", "uploads", filename) , "w") do |csv|
        csv << results_csv.first.keys
        results_csv.each do |hash|
          csv << hash.values
        end
      end
      
      File.open(File.join(Rails.root, "public", "uploads", "geohexes-#{filename}"), 'w') do |file| 
        file.write(geohexes.flatten.uniq.join("\n"))
      end
      
    end
  
end
