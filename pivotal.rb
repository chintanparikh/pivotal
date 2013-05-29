#!/usr/bin/env ruby

require 'pivotal-tracker'
require 'yaml'
require 'debugger'

# pivotal next - Display information about your next project
# pivotal estimate (1-8)
# pivotal start (next|ID) - marks story as started, creates new git branch
# git commit, push, etc, etc
# pivotal complete

TEMP_DIR = "#{ENV['HOME']}/.pivotal/" 
TEMP_FILE = TEMP_DIR + "temp.yml"
CONFIG_FILE = TEMP_DIR + "config.yml"

unless File.directory? TEMP_DIR
  Dir::mkdir TEMP_DIR
end

unless File.file? TEMP_FILE
  f = File.open(TEMP_FILE, 'w')
  f.write("id: -1")
end
# TEMP FILE format:
  # current_story_id: 123 OR -1

PivotalTracker::Client.token('chintan@myaidin.com', 'gp317a45')

aidin = PivotalTracker::Project.all.first
current_id = nil
# next_story = aidin.stories.all(owner: 'Chintan Parikh', state: 'unstarted').first

# puts "id: #{next_story.id}"
# puts next_story.name
# puts next_story.description
# puts "estimate: #{(next_story.estimate == -1) ? 'unestimated' : next_story.estimate}"
# puts "branch_name: feature/#{next_story.id}_#{next_story.name.downcase.gsub(' ', '_').gsub(/[^0-9A-Za-z_]/, '')}"

def story_info story
  puts story.name
  puts "id:\t\t#{story.id}"
  puts "notes:\t\t#{story.description}"
  puts "estimate:\t#{(story.estimate == -1) ? 'unestimated' : story.estimate}"
end

def is_next string
  string == 'next'
end

def id string
  !string.match(/^[\d]+(\.[\d]+){0,1}$/).nil?
end

def current string
  string == 'current'
end

def story_has_been_started
  f = YAML.load_file(TEMP_FILE)
  current_id = f['id']
  f['id'] == -1
end


case ARGV[0]
when "info"
  # pivotal info next
  # pivotal info id
  # pivotal info current

  if is_next(ARGV[1])
    puts "\033[32mDisplaying information for next story\033[0m\n"
    story_info(aidin.stories.all(owner: 'Chintan Parikh', state: 'unstarted').first)

  elsif id(ARGV[1])
    story = aidin.stories.find(Integer(ARGV[1]))
    unless story.nil?
      puts "\033[32mDisplaying information for story #{ARGV[1]}\033[0m\n"
      story_info(story)
    else
      puts "\033[33mNo story with id #{ARGV[1]} exists\033[0m\n"
    end
    
  elsif current(ARGV[1])
    if story_has_been_started
      puts "\033[32mDisplaying information for current story\033[0m\n"
      story_info()
    else    
      puts "\033[33mNo story has been started. Use pivotal start to start a story first\033[0m\n"
    end
  end

when "estimate"
  # pivotal estimate next 1-8
  # pivotal estimate id 1-8
  # pivotal estimate current 1-8

when "start"
  # pivotal start next
  # pivotal start id
  if story_has_been_started
    current_branch = `git branch | grep "*" | sed "s/* //"`
    status = `git status -s`
    debugger
    puts "\033[33mYou are currently working on story #{current_id}. If you continue, your uncommitted changes will be lost. Continue? (Y/N)\033[0m\n"
    continue = false
    while (!continue)
      option = $stdin.gets.chomp
      if option == 'N'
        exit 1
      elsif option != 'Y'
        puts "Please enter either Y or N"
      else
        continue = true;
      end
    end
  end


  # Ensure next story has estimate
  # git checkout develop
  # git pull
  # git checkout -b feature/blahblahblah
  # mark story as started
  # puts some kind of message to start working
when "complete"
  # mark story as finished and delivered
when 'set'
  # set username, password
end
