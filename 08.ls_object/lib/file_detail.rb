#!/usr/bin/env ruby
# frozen_string_literal: true

class FileDetail
  attr_reader :path, :name, :attribute, :nlink, :uname, :gname, :size, :time, :symlink

  PERMISSIONS = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

  def initialize(path:, name:)
    @path = analyze_path(path: path, name: name)
    @stat = File.lstat(@path) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
    @attribute = analyze_attribure
    @nlink = analyze_nlink
    @uname = analyze_user_name
    @gname = analyze_group_name
    @size = analyze_size
    @time = analyze_time
    @name = analyze_symlink(name: name)
  end

  private

  def analyze_path(path:, name:)
    path.nil? ? name : "#{path}/#{name}"
  end

  def analyze_attribure
    "#{type_to_s}#{permit_to_s}"
  end

  def type_to_s
    { file: '-', directory: 'd', link: 'l' }[File.ftype(@path).intern]
  end

  def permit_to_s
    owener = ((@stat.mode >> 6) % 8)
    group = ((@stat.mode >> 3) % 8)
    other = @stat.mode % 8
    "#{PERMISSIONS[owener]}#{PERMISSIONS[group]}#{PERMISSIONS[other]}"
  end

  def analyze_nlink
    @stat.nlink
  end

  def analyze_user_name
    Etc.getpwuid(@stat.uid).name
  end

  def analyze_group_name
    Etc.getgrgid(@stat.gid).name
  end

  def analyze_size
    @stat.size
  end

  def analyze_time
    month = @stat.mtime.to_a[4].to_s.rjust(2)
    day = @stat.mtime.to_a[3].to_s.rjust(2)
    clock = @stat.mtime.to_a[2].to_s.rjust(2, '0')
    minitus = @stat.mtime.to_a[1].to_s.rjust(2, '0')
    "#{month} #{day} #{clock}:#{minitus}"
  end

  def analyze_symlink(name:)
    @stat.symlink? ? "#{@path} -> #{File.readlink(@path)}" : name
  end
end
