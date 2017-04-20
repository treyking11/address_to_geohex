require 'csv'
require 'geo_hex/coverage'

class ReverseGeocoderController < ApplicationController

  def create
    # timestamp = Time.now.to_i
    @addy_file_path = "/uploads/address-#{params['locations'].original_filename}"
    process_tempfile params['locations'].tempfile, @addy_file_path
  end

private

  def process_tempfile temp_file, addy_filename
    results_csv = []
    CSV.foreach(temp_file, headers: true) do |row|
      query                             = [row['latitude'], row['longitude']].join(', ')
      row['address_1'] = Geocoder.address(query)
      results_csv << row.to_hash
    end

    CSV.open(File.join(Rails.root, "public", addy_filename), "w") do |csv|
      csv << results_csv.first.keys
      results_csv.each do |hash|
        csv << hash.values
      end
    end
  end

end



# Geocoder::Calculations.geographic_center([city1, city2, [40.22,-73.99], city4])
