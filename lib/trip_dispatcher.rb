require 'csv'
require 'time'

require_relative 'passenger'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(directory: './support')
      @drivers = Driver.load_all(directory: directory)
      @passengers = Passenger.load_all(directory: directory)
      @trips = Trip.load_all(directory: directory)
      connect_trips
    end

    def find_driver(id)
      Driver.validate_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    def find_passenger(id)
      Passenger.validate_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def request_trip(passenger_id)
      driver = @drivers.find { |driver| driver.status == :AVAILABLE }

      if driver == nil
        raise ArgumentError.new("No available drivers")
      else
        passenger = find_passenger(passenger_id)
        id = (@trips.last.id + 1)
        driver_id = driver.id
        new_trip = RideShare::Trip.new(
          id: id,
          driver_id: driver_id,
          passenger_id: passenger_id,
          start_time: Time.now,
          end_time: nil,
          cost: nil,
          rating: nil
        )
        new_trip.connect(passenger, driver)
        @trips << new_trip
        driver.status = :UNAVAILABLE
        return new_trip
      end
    end

    def inspect
      # Make puts output more useful
      return "#<#{self.class.name}:0x#{object_id.to_s(16)} \
              #{trips.count} trips, \
              #{drivers.count} drivers, \
              #{passengers.count} passengers>"
    end

    private

    def connect_trips
      @trips.each do |trip|
        passenger = find_passenger(trip.passenger_id)
        driver = find_driver(trip.driver_id)
        trip.connect(passenger, driver)
      end

      return trips
    end
  end
end

td = RideShare::TripDispatcher.new
#pp td.trips
pp td.find_driver(1)
pp td.request_trip(40)
pp td.trips.last.driver.status
pp td.trips.last.passenger
