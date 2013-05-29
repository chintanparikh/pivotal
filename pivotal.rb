#!/usr/bin/env ruby

require 'pivotal-tracker'
require 'yaml'
require 'debugger'

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
@current_id = nil

def story_info story
  puts story.name
  puts "id:\t\t#{story.id}"
  puts "notes:\t\t#{story.description}"
  puts "status:\t\t#{story.current_state}"
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
  @current_id = f['id']
  f['id'] != -1
end

def update_id id
  f = File.open(TEMP_FILE, 'w')
  f.write("id: #{id}")
  @current_id = id
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
      story = aidin.stories.find(@current_id)
      puts "\033[32mDisplaying information for current story\033[0m\n"
      story_info(story)
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
    current_branch = `git branch | grep "*" | sed "s/* //"`.chomp
    status = `git status -s`
    if !status.empty?
      puts "\033[33mYou are currently working on story #{@current_id} and have uncommitted changes on #{current_branch}. If you continue, your uncommitted changes will be lost. Continue? (Y/N)\033[0m\n"
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
  end

  `git stash`
  `git stash drop`
  `git checkout develop`
  `git pull`

  if is_next(ARGV[1])
    story = aidin.stories.all(owner: 'Chintan Parikh', state: 'unstarted').first
    new_branch = "feature/#{story.id}_#{story.name.downcase.gsub(' ', '_').gsub(/[^0-9A-Za-z_]/, '')}"
    `git checkout -b #{new_branch}`
  elsif id(ARGV[1])
    story = aidin.stories.find(Integer(ARGV[1]))
    unless story.nil?
      new_branch = "feature/#{story.id}_#{story.name.downcase.gsub(' ', '_').gsub(/[^0-9A-Za-z_]/, '')}"
      `git checkout -b #{new_branch}`
    else
      puts "\033[33mNo story with id #{ARGV[1]} exists\033[0m\n"
    end
  end

  update_id(story.id) unless story.nil?
  story.update(current_state: 'started')

  puts "\033[32mStory #{story.id} has been started\033[0m\n"
  story_info(story)

when "complete"
  if story_has_been_started
    story = aidin.stories.find(@current_id)
    branch = "feature/#{story.id}_#{story.name.downcase.gsub(' ', '_').gsub(/[^0-9A-Za-z_]/, '')}"
    `git push origin #{branch}`
    story.update(current_state: 'finished')
    story.update(current_state: 'delivered')
    
    puts "\033[32mStory #{story.id} has been completed\033[0m\n"
    update_id(-1)
  else
    puts "\033[33mNo story has been started. Use pivotal start to start a story first\033[0m\n"
  end
  
when 'abandon'
  if story_has_been_started
    story = aidin.stories.find(@current_id)
    story.update(current_state: 'unstarted')
    
    puts "\033[32mStory #{story.id} has been abandoned\033[0m\n"
    update_id(-1)
  else
    puts "\033[33mNo story has been started. Use pivotal start to start a story first\033[0m\n"
  end

when 'list'
  stories = aidin.stories.all(owner: 'Chintan Parikh', current_state: ['unstarted', 'started', 'finished', 'delivered'])
  stories.each do |story|
    story_info(story)
  end
when 'set'
  # set username, password
end
