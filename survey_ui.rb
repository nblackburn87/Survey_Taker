require 'active_record'

require './lib/surveys'
require './lib/questions'
require './lib/responses'


database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

I18n.enforce_available_locales = false


def main_menu

  choice = nil
  until choice == 'exit'
    puts "Enter any key to find a survey to take."
    puts "Enter 'login' to enter the designer portal."
    puts "Enter 'exit' to leave the survey portal."
    choice = get_input('Enter your choice:').downcase
    case choice
    when 'login'
      designer_menu
    when 'exit'
      puts "Thank you for your visit."
    else
      taker_menu
    end
  end
end

def designer_menu
  puts "Press 'a' to add a new survey."
  puts "Press 'l' to list surveys."
  puts "Press 'q' to add questions to an existing survey."
  puts "Press 'x' to return to the main menu."
  choice = get_input('Enter your choice:').downcase

  case choice
  when 'a'
    add_survey
    designer_menu
  when 'l'
    list_surveys
    designer_menu
  when 'q'
    add_questions
    designer_menu
  when 'x'
    puts 'Returning to main menu.'
  else
    puts "That is not a valid input."
    designer_menu
  end
end

def add_survey
  user_input = get_input("What is the name of your survey?")
  new_survey = Survey.new({ :name => user_input })
  if new_survey.save
    puts "Created #{new_survey.name}"
  else
    puts "That survey already exists. Try creating your new survey with a different name."
  end
end

def add_questions
  list_surveys
  selected_survey = get_input("What survey would you like to add questions to?")
  survey = Survey.find_by_name(selected_survey)
  add_another = 'y'
  until add_another == 'n'
    prompt = get_input("Please input your question:")
    created_question = survey.questions.create({ :prompt => prompt })
    puts "Your question '#{created_question.prompt}' was created."
    add_another = get_input("Do you want to add another question to this survey? (y/n)").downcase
  end
  list_questions(survey)
end

def list_questions(survey)
  puts "--#{survey.name} "
  puts "---Here are your questions:"
  survey.questions.each_with_index do |question, index|
    puts "#{index + 1}. #{question.prompt}"
  end
  puts "-"*20 + "\n"
end

#******************************************

def taker_menu
end

#*******************************************

def get_input(question)
  puts question
  gets.chomp
end

def list_surveys
  puts "--Surveys" + "-"*11
  Survey.all.each do |survey|
    puts survey.name
  end
  puts '-'*20 + "\n"
end

system "clear"
puts 'Welcome to the Survey Center'
main_menu
