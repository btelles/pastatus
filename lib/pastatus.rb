
#== Usage
#  This command records the current passenger status to file 'foo.txt'.
#  It appends data if the file already exists.
#    +pastatus foo.txt+
require 'rubygems'
require File.dirname(__FILE__) + '/pastatus/passenger_parser'
require File.dirname(__FILE__) + '/pastatus/passenger_log_record'

class Pastatus
  VERSION = '0.0.1'

  attr_reader :options

  def initialize(arguments)
    @arguments = arguments[0]

  end

  def run

    if @arguments == '-h' || @arguments == '--help'
      output_usage
    elsif @arguments.nil?
      puts "Please provide a file path"
    else
      process_command
    end
  end

  protected

    def output_usage
      puts File.open(File.expand_path(File.dirname(__FILE__) + '/../README.rdoc')).read # gets usage from comments above
    end

    def process_command
      p = PassengerParser.new(:local_passenger => true)
      p.process_status(@arguments)
    end

end


