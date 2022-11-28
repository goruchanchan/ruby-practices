#!/usr/bin/env ruby
# frozen_string_literal: true

def argument_parsing
  raw_argument = []
  ARGV.each do |argument|
    break unless argument.include?('-')

    raw_argument.push(argument)
  end

  options = []
  raw_argument.each do |option|
    options.push('-a') if option.include?('a')
    options.push('-r') if option.include?('r')
    options.push('-l') if option.include?('l')
  end

  { argument: raw_argument, argument_option: options }
end

def argv_parsing
  file_paths = []
  directory_paths = []
  error_paths = []

  argument = argument_parsing

  (ARGV - argument[:argument]).each do |path|
    if FileTest.directory?(path)
      directory_paths.push(path)
    elsif FileTest.file?(path)
      file_paths.push(path)
    else
      error_paths.push(path)
    end
  end

  directory_paths.push('.') if file_paths.empty? && directory_paths.empty? && error_paths.empty?

  { file: file_paths.sort, directory: directory_paths.sort, error: error_paths.sort, option: argument[:argument_option].sort }
end
