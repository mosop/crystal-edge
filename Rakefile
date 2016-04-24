require "fileutils"
require "open3"
require "stringio"

class Out
  def initialize
    @stdout = STDOUT.clone
    @reader, @writer = IO.pipe
  end

  def result
    @writer.close_write
    @reader.read
  end

  def method_missing(name, *args, &block)
    @stdout.__send__ name, *args, &block
    @writer.__send__ name, *args, &block
  end
end

def run(cmd, output: true, chdir: nil)
  puts "#{chdir || "(current dir)"}: #{cmd}"
  out = Out.new
  options = {}
  options[:out] = out
  options[:chdir] = chdir if chdir
  Process.waitpid spawn(cmd, options)
  raise "Command error: #{cmd}" unless $?.success?
  out.result
end

def find_latest_version_tag(tags)
  tags = tags.find_all{|i| /^v\d/ =~ i && !i.include?("-")}
  tags.sort{|a, b| compare_version_tags(a, b)}.last
end

def compare_version_tags(a, b)
  av = a[1..-1].split(".").map(&:to_i)
  bv = b[1..-1].split(".").map(&:to_i)
  ([av.size, bv.size].max - av.size).times{av << 0}
  ([av.size, bv.size].max - bv.size).times{bv << 0}
  for i in 0..(av.size-1)
    n = av[i] <=> bv[i]
    return n if n != 0
  end
  0
end

def get_commit(repo)
  run("git rev-parse --verify HEAD", chdir: repo).strip
end

REPO_DIR = "#{__dir__}/repo"
CRYSTAL_DIR = "#{REPO_DIR}/crystal"

def crystal_commit
  @crystal_commit ||= get_commit(CRYSTAL_DIR)
end

def build_dir
  @build_dir ||= "#{__dir__}/build/#{crystal_commit}"
end

def release_dir
  @release_dir ||= "#{build_dir}/release"
end

namespace :build do
  task :config do
    CRYSTAL_BIN = "#{CRYSTAL_DIR}/.build/crystal"
    CRYSTAL_COPY_OBJECTS = %w(etc src)

    SHARDS_DIR = "#{REPO_DIR}/shards"
    run "git fetch", chdir: SHARDS_DIR
    SHARDS_TAG = find_latest_version_tag(run("git tag", chdir: SHARDS_DIR).split("\n"))
    SHARDS_BIN = "#{SHARDS_DIR}/bin/shards"

    RELEACE_BIN_DIR = "#{release_dir}/bin"
    RELEASE_SHARDS_BIN = "#{RELEACE_BIN_DIR}/shards"
  end

  task :release => :config do
    run "rm -rf #{release_dir}" if File.exist?(release_dir)
    run "mkdir -p #{RELEACE_BIN_DIR}"
    run "make", chdir: CRYSTAL_DIR
    run "cp #{CRYSTAL_BIN} #{RELEACE_BIN_DIR}/"
    CRYSTAL_COPY_OBJECTS.each{|i| run "cp -r #{CRYSTAL_DIR}/#{i} #{release_dir}/"}
    run "git checkout #{SHARDS_TAG}", chdir: SHARDS_DIR
    run "make", chdir: SHARDS_DIR
    run "cp #{SHARDS_BIN} #{RELEACE_BIN_DIR}/"
  end
end

namespace :crenv do
  task :install do
    versions_dir = File.expand_path('../../versions', run("which crenv").strip)
    run "ln -sf #{release_dir} #{versions_dir}/edge"
  end
end
