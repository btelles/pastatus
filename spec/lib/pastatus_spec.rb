require File.dirname(__FILE__) + '/../spec_helper'
describe PassengerParser do
  PassengerParser.class_eval do
    send(:attr_accessor, :results)
    send(:public, :remove_common_data_lines)
  end

  it 'should raise when given a file path with no matching files' do
    lambda {
      PassengerParser.new(:directory_pattern => 'invalid_fixtures/*.msg')
    }.should raise_error EmptyPassengerLogDirectory
  end
  it 'should take a given file path' do
    PassengerParser.new(:directory_pattern => File.dirname(__FILE__)+'/../fixtures/*.msg').should be_an_instance_of PassengerParser 
  end
  
  describe 'remove_common_data_lines' do
    it 'should keep all remaining lines' do
      @pp = PassengerParser.new(:directory_pattern => File.dirname(__FILE__) + '/../fixtures/*.msg')
      body ="\e[33m\e[44m\e[1m----------- General information -----------\e[0m\r\nmax      = 10\r\ncount    = 10\r\nactive   = 0\r\ninactive = 10\r\nWaiting on global queue: 0\r\n\r\n\e[33m\e[44m\e[1m----------- Domains -----------\e[0m\r\n/opt/common/html/mdxway: \r\n  PID: 11753   Sessions: 0    Processed: 555     Uptime: 4h 56m 41s\r\n\r\n"
      @pp.remove_common_data_lines(body.split("\r\n")).should have(2).items
    end
  end
  describe 'parse one file' do
  require 'ruby-debug'
    before do
      @pp = PassengerParser.new(:directory_pattern => File.dirname(__FILE__) + '/../fixtures/*.msg')
      @pp.process_status
    end

    after do
      FileUtils.rm(File.dirname(__FILE__)+'/../../results.csv') if File.exist?(File.dirname(__FILE__)+'/../../results.csv')
    end

    it 'should create its own csv results file' do
      File.exist?(File.dirname(__FILE__)+'/../../results.csv').should == true
    end
    it 'should create a FasterCSV Table' do
      @pp.results.should be_an_instance_of FasterCSV::Table
    end
    it 'should store the server name of a given email log' do
      @pp.results[0]['server'].should == 'sun114z1.dms.state.fl.us'
    end
    it 'should find a path to an application' do
      @pp.results[0]['application'].should == '/opt/common/html/mdxway'
    end
    it 'should find the hours of up time for an application' do
      @pp.results[0]['uptime_h'].should == '4'
    end
    it 'should find the minutes of up time for an application' do
      @pp.results[0]['uptime_m'].should == '56'
    end
    it 'should find the seconds of up time for an application' do
      @pp.results[0]['uptime_s'].should == '41'
    end
    it 'should find the requests ana application has had' do
      @pp.results[0]['requests'].should == '555'
    end
    it 'should find the number of sessions' do
      @pp.results[0]['sessions'].should == 0
    end
    it 'should find the status log time' do
      @pp.results[0]['created_at'].should == DateTime.strptime("2009-08-18T22:00:05+00:00") 
    end
    it 'should have 10 records' do
      @pp.results.size.should == 10
    end
    describe "output file" do
      before do
        @file = FasterCSV.table(File.dirname(__FILE__)+'/../../results.csv')
      end
      it 'should output each record to a csv file' do
        @file.size.should == 10
      end
      it 'should not have any nil columns if the record was full' do
        cloned_record = FasterCSV::Row.new([:server, :max, :count, :active, :inactive, :waiting_on_global_queue, :created_at,
                  :uptime_h, :uptime_m, :uptime_s, :requests, :application, :sessions, :pid],
                  ['sun114z1.dms.state.fl.us',10,10,0,10,0,"2009-08-18T22:00:05+00:00",4,56,41,555,
                  "/opt/common/html/mdxway",0,0])
        @file[0].should == cloned_record
      end
    end
  end
  describe "retrieve from local passenger instance" do
    before do
      text_results = <<-CURRENT_STATUS
[33m [44m [1m----------- General information ----------- [0m
max      = 10
count    = 10
active   = 0
inactive = 10
Waiting on global queue: 0

[33m [44m [1m----------- Domains ----------- [0m
/opt/common/html/mdxway: 
PID: 11753   Sessions: 0    Processed: 555     Uptime: 4h 56m 41s

/opt/common/html/railsapps/directory/current: 
PID: 28146   Sessions: 0    Processed: 9       Uptime: 4h 34m 7s

/opt/common/html/railsapps/feedback: 
PID: 29626   Sessions: 0    Processed: 42      Uptime: 93h 38m 2s

/opt/common/html/railsapps/osd: 
PID: 15399   Sessions: 0    Processed: 3739    Uptime: 105h 8m 39s

/opt/common/html/railsapps/privateprison: 
PID: 20471   Sessions: 0    Processed: 140     Uptime: 25h 2m 15s

/opt/common/html/railsapps/software/current: 
PID: 2665    Sessions: 0    Processed: 1740    Uptime: 75h 59m 45s

/opt/common/html/rubyapps/governor: 
PID: 25358   Sessions: 0    Processed: 2647    Uptime: 30h 14m 7s
PID: 24201   Sessions: 0    Processed: 1925    Uptime: 30h 15m 18s

/opt/common/html/ssrc: 
PID: 11363   Sessions: 0    Processed: 1915    Uptime: 105h 13m 20s

/opt/common/html/ssrcdev: 
PID: 23331   Sessions: 0    Processed: 5       Uptime: 14h 59m 17s


CURRENT_STATUS
      @pp = PassengerParser.new(:local_passenger => true)
      @pp.should_receive(:local_status).and_return(text_results.gsub(/^\n/,''))
      @pp.should_receive(:local_host).and_return('sun114z1.dms.state.fl.us')
      @d = DateTime.now
      DateTime.should_receive(:now).and_return(@d)
      @pp.process_status
    end

    after :all do
      FileUtils.rm(File.dirname(__FILE__)+'/../../results.csv') if File.exist?(File.dirname(__FILE__)+'/../../results.csv')
    end

    it 'should create its own csv results file' do
      File.exist?(File.dirname(__FILE__)+'/../../results.csv').should == true
    end
    it 'should create a FasterCSV Table' do
      @pp.results.should be_an_instance_of FasterCSV::Table
    end
    it 'should store the server name of a given email log' do
      @pp.results[0]['server'].should == 'sun114z1.dms.state.fl.us'
    end
    it 'should find a path to an application' do
      @pp.results[0]['application'].should == '/opt/common/html/mdxway'
    end
    it 'should find the hours of up time for an application' do
      @pp.results[0]['uptime_h'].should == '4'
    end
    it 'should find the minutes of up time for an application' do
      @pp.results[0]['uptime_m'].should == '56'
    end
    it 'should find the seconds of up time for an application' do
      @pp.results[0]['uptime_s'].should == '41'
    end
    it 'should find the requests ana application has had' do
      @pp.results[0]['requests'].should == '555'
    end
    it 'should find the number of sessions' do
      @pp.results[0]['sessions'].should == 0
    end
    it 'should find the status log time' do
      @pp.results[0]['created_at'].should == @d
    end
    it 'should have 60 records' do
      @pp.results.size.should == 10
    end
    it "the file should have xx records" do
      rows = 0
      File.open(File.dirname(__FILE__)+'/../../results.csv').readlines.each { rows = rows + 1 }
      rows.should == 121
    end
  end
end
