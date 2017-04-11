require 'geo_hex'
module GeoHex
  #
  # GeoHex Coverage by latitude/latitude
  #
  class Coverage < GeoHex::LL
    METERS_RANGE = (100..1_000_000).freeze
    MAX_LEVEL    = 9
    PRECISION    = 3
    ACCURACY     = 0.9

    def initialize(lat, lon)
      super(lat.to_f, lon.to_f)
    end

    # @param [Integer] meters radius in meters
    # @param [Integer] precision precision factor
    # @return [GeoHex::Zone] the best suited centroid zone
    def centroid(meters, precision = PRECISION)
      return nil unless METERS_RANGE.include?(meters)

      threshold = meters.fdiv(precision + 1)
      MAX_LEVEL.downto(0) do |level|
        zone   = ::GeoHex.encode(lat, lon, level)
        height = zone.polygon.north.to_ll.distance_to(zone.polygon.south.to_ll)
        return zone if height > threshold
      end && nil
    rescue Math::DomainError
      nil
    end

    # @param [Integer] meters radius in meters
    # @param [Hash] opts options
    # @option [Integer] opts :precision precision factor
    # @option [Integer] opts :accuracy accuracy factor
    # @return [Array<GeoHex::Zone>] zones within `meters` at `precision`
    def within(meters, opts = {})
      precision = opts[:precision] || PRECISION
      accuracy  = opts[:accuracy] || ACCURACY
      centre    = centroid(meters, precision)
      return [] unless centre

      centre.neighbours(precision).reject do |zone|
        zone.point.to_ll.distance_to(self) * accuracy > meters
      end << centre
    end
  end
end
