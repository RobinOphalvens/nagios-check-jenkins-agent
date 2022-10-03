#!/usr/bin/env ruby
# frozen_string_literal: true

# This Nagios script checks if a given host is connected to a given Jenkins instance as an
# eligable Swarm client.
#
# Return OK if Jobs can be build and CRIT if we're offline without a valid reason
#
# Users can mark if temporarily offline nodes should return WARN or OK.
require 'optparse'
require 'httparty'

url = nil
user = nil
password = nil
host = `hostname`
temp_off_state = 'WARN'

opt = OptionParser.new

opt.on('--instance [URL]', '-i', 'Base URL of the Jenkins Controller') do |f|
  url = f
end

opt.on('--host [HOST]', '-h', 'Optionally override host to check. This is the hostname by default') do |f|
  host = f
end

opt.on('--user [USER]', '-u', 'Authentication username.') do |f|
  user = f
end

opt.on('--password [PASSWORD]', '-p', 'Authentication password.') do |f|
  password = f
end

opt.on(
  '--temp-offline-state [STATE]',
  '-t',
  'Report temporarily offline nodes as: OK, WARN or CRIT. Warning is default'
) do |f|
  temp_off_state = f
end

opt.parse!

response = nil

begin
  if url.nil?
    puts 'CRITICAL: Please provide a valid Jenkins URL!'
    exit 2
  end
  auth = { username: user, password: password }
  response = HTTParty.get("#{url}/manage/computer/api/json", basic_auth: auth)
  raise 'UNKNOWN: Invalid credentials' if response.code == 401

  if response.body.nil? || response.body.empty?
    raise 'Failed to fetch computers. Please check the URL and/or credentials'
  end

  response.parsed_response
rescue StandardError => e
  puts e.message
  exit 3
end

begin
  data = response['computer'].select { |computer| computer['displayName'] == host }
  raise "UNKNOWN: #{host} is not a part of the #{url} swam cluster!" if data.empty?
rescue StandardError => e
  puts e.message
  exit 3
end

if data[0]['offline']
  offline_reason = data[0]['offlineCauseReason']
  if data[0]['temporarilyOffline']
    case temp_off_state
    when 'WARN'
      puts "WARNING: #{host} has been manually marked offline from #{url} with reason: #{offline_reason}"
      exit 1
    when 'CRIT'
      puts "CRITICAL: #{host} has been manually marked offline from #{url}! Reason: #{offline_reason}"
      exit 2
    when 'OK'
      puts "OK: #{host} has been manually marked offline from #{url} with reason: #{offline_reason}"
      exit 0
    else
      puts "WARNING: #{host} has been manually marked offline from #{url} with reason: #{offline_reason}"
      exit 1
    end
  end
  puts "CRITICAL: #{host} is offline from #{url}! Reason #{offline_reason}"
  exit 2
else
  puts "OK: #{host} is connected to #{url}"
  exit 0
end
