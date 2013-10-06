#!/usr/bin/env ruby

require 'fileutils'

def wait_until_new_file(directory)
  files_before = Dir.entries(directory)

  yield

  new_files = []
  while new_files.size != 1
    new_files = Dir.entries(directory) - files_before
    sleep 0.5
  end

  return new_files[0]
end

def wait_file_and_rename_to(new_name, options={directory: '.'}, &block)
  directory = options[:directory]
  filename = wait_until_new_file(directory) do
    block.yield if (block)
  end

  FileUtils.mv("#{directory}/#{filename}", "#{directory}/#{new_name}")
end

# Example:
#
# wait_file_and_rename_to 'test', directory: 'downloads' do
#   sleep 1
#   FileUtils.touch("downloads/a")
# end