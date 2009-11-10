require 'rake'
require 'fastercsv'
require 'mapi/msg'
class EmptyPassengerLogDirectory < StandardError; end

# =Usage
#
# ===For Outlook email messages
# 
# +pp = PassengerParser.new(directory_pattern)+
# +pp.process_results+
# => creates a csv file with log output
#
#
# ===For direct from server
#
# +pp = PassengerParser.new(:local_passenger => true)+
# +pp.process_results(_optional_file_path_)+
# => appends lines to _optional_file_path_, creates file if it doesn't exist 
#
class PassengerParser
  attr_accessor :file_list
  
  
  def initialize(*args)
    if args[0][:local_passenger]
      @retrieve_type = :local
    else
      pattern = args[0][:directory_pattern] || 'messages/*.msg'
      @file_list = FileList.new(pattern)
      if @file_list.empty?
        raise EmptyPassengerLogDirectory
      end
    end
  end

  def process_status(file_path = nil)
    @results_path = file_path || File.dirname(__FILE__)+'/../../results.csv'
    if @retrieve_type == :local
      @current_status = local_status
      @current_host = local_host
      store_local_status if @current_status.match(/^\//)
    else
      store_email_statuses
    end
  end

  def local_status
    `sudo passenger-status`
  end

  def local_host
    `hostname`
  end

  def store_email_statuses
    @results= FasterCSV::Table.new([])
    @file_list.each do |file_name|
      msg = Mapi::Msg.open(file_name)
      process_one_message(msg)
      msg.close
    end
    write_file
  end

  def write_file(write_mode = 'w')
    add_headers = !(File.exist?(@results_path)) || File.open(@results_path).read(6) != 'server'
    FasterCSV.open(@results_path, write_mode, {:headers => true}) do |file|
      file << @results.headers if add_headers
      @results.each {|r| file << r }
    end
  end

  def process_one_message(msg)
    body = msg.properties.body
    @common_data.clear if @common_data
    @common_data = {
      :server => msg.properties.sender_email_address.match(/\@(.*)/)[1],
      :created_at => DateTime.strptime(msg.properties.transport_message_headers.match(/Date\:(.*), (.*) \-/)[2],'%d %b %Y %H:%M:%S') 
    }.merge(data_common_to_emails_and_local_retrieve(body))
    body = remove_common_data_lines body.split("\r\n")
    application_records(body)
  end
  
  def store_local_status
    @results= FasterCSV::Table.new([])
    process_current_data
    write_file('a+')
  end

  def process_current_data
    @common_data.clear if @common_data
    @common_data = {
      :server => @current_host.gsub(/\n/,''),
      :created_at => DateTime.now
    }.merge(data_common_to_emails_and_local_retrieve(@current_status))
    @current_status = remove_common_data_lines @current_status.split("\n")
    application_records(@current_status)
  end

  def data_common_to_emails_and_local_retrieve(body)
    { :max => body.match(/max\s+=\s+(\d+)/)[1],
      :count => body.match(/count\s+=\s+(\d+)/)[1],
      :active => body.match(/active\s+=\s+(\d+)/)[1],
      :inactive => body.match(/inactive\s+=\s+(\d+)/)[1],
      :waiting_on_global_queue => body.match(/waiting on global queue\:\s+(\d+)/i)[1],
    }
  end

  def remove_common_data_lines(body)
    body.each_index do |i| 
      break if @domain_line
      @domain_line = i if body[i] =~ /\-\-\- Domains \-\-\-/
    end
    (@domain_line + 1 ).times { body.shift }
    body
  end

  def application_records(body)
    body.each do |line|
      if ! new_application line
        add_record line unless line.empty? || line.nil?
      else
        create_new_application_with line
      end
    end
  end

  def new_application(line)
    line =~ /^\//
  end

  def create_new_application_with(line)
    @current_application = line
  end

  def add_record line
    uptime_h = (line.match(/\s(\d+)h/)[1] rescue 0)
    uptime_m = (line.match(/\s(\d+)m/)[1] rescue 0)
    uptime_s = (line.match(/\s(\d+)s/)[1] rescue 0)
    requests = (line.match(/Processed\:\s(\d+)/)[1] rescue 0)
    pid      = (line.match(/PID\s(\d+)/)[1] rescue 0)
    sessions = (line.match(/Sessions\s(\d+)/)[1] rescue 0)
    @results << PassengerLogRecord.new(@common_data,{
      :application => @current_application.gsub(/\: /, ''),
      :uptime_h => uptime_h,
      :uptime_m => uptime_m,
      :uptime_s => uptime_s,
      :requests => requests,
      :pid      => pid     ,
      :sessions => sessions
    })
  end
end
