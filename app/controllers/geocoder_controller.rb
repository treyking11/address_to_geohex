require 'csv'
require 'geo_hex/coverage'
class GeocoderController < ApplicationController

  def index

  end

  def create
    timestamp = Time.now.to_i
    @ll_file_path = "/uploads/#{timestamp}-ll-#{params['locations'].original_filename}"
    @gh_file_path = "/uploads/#{timestamp}-gh-#{params['locations'].original_filename}"
    process_tempfile params['locations'].tempfile, @ll_file_path, @gh_file_path
  end

  private




  def process_tempfile temp_file, ll_filename, gh_filename
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

    CSV.open(File.join(Rails.root, "public", ll_filename), "w") do |csv|
      csv << results_csv.first.keys
      results_csv.each do |hash|
        csv << hash.values
      end
    end

    File.open(File.join(Rails.root, "public", gh_filename), 'w') do |file|
      file.write(geohexes.flatten.uniq.join("\n"))
    end
  end

end
