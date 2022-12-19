# frozen_string_literal: true

class FileDetail
  PERMISSIONS = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

  def initialize(input_path:, input_name:)
    @input_path = input_path
    @input_name = input_name
    @stat = File.lstat(path) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
  end

  def path
    @input_path.nil? ? @input_name : "#{@input_path}/#{@input_name}"
  end

  def attribute
    "#{type_to_s}#{permit_to_s}"
  end

  def nlink
    @stat.nlink
  end

  def uname
    Etc.getpwuid(@stat.uid).name
  end

  def gname
    Etc.getgrgid(@stat.gid).name
  end

  def size
    @stat.size
  end

  def time
    month = @stat.mtime.to_a[4].to_s.rjust(2)
    day = @stat.mtime.to_a[3].to_s.rjust(2)
    clock = @stat.mtime.to_a[2].to_s.rjust(2, '0')
    minitus = @stat.mtime.to_a[1].to_s.rjust(2, '0')
    "#{month} #{day} #{clock}:#{minitus}"
  end

  def name
    @stat.symlink? ? "#{@input_path} -> #{File.readlink(@input_path)}" : @input_name
  end

  private

  def type_to_s
    { file: '-', directory: 'd', link: 'l' }[File.ftype(path).intern]
  end

  def permit_to_s
    owener = ((@stat.mode >> 6) % 8)
    group = ((@stat.mode >> 3) % 8)
    other = @stat.mode % 8
    "#{PERMISSIONS[owener]}#{PERMISSIONS[group]}#{PERMISSIONS[other]}"
  end
end
