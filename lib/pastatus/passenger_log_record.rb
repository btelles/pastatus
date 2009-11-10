require 'fastercsv'
class PassengerLogRecord < FasterCSV::Row
  def initialize(common_data, body)
    @headers = %w{server max count active inactive waiting_on_global_queue created_at
                  uptime_h uptime_m uptime_s requests application sessions pid}
    data = [ common_data[:server],
             common_data[:max],
             common_data[:count],
             common_data[:active],
             common_data[:inactive],
             common_data[:waiting_on_global_queue],
             common_data[:created_at],
             body[:uptime_h],
             body[:uptime_m],
             body[:uptime_s],
             body[:requests],
             body[:application],
             body[:sessions],
             body[:pid]
    ]
    super(@headers, data)
  end
end
