require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"
require "yaml"

module Build
  extend self

  OS = begin
    os = RbConfig::CONFIG["host_os"]
    case
    when /linux/ =~ os
      "linux"
    when /darwin/ =~ os
      "darwin"
    else
      raise "OS not supported: #{os}"
    end
  end

  def linux?
    OS == "linux"
  end

  def darwin?
    OS == "darwin"
  end

  ROOT_DIR = __dir__
  CRYSTAL_GIT_URL = "https://github.com/crystal-lang/crystal.git"
  BDWGC_VERSION = "7_6_0"
  LIBATOMIC_OPS_VERSION = "7_4_4"
  EXT_DIR = File.join(ROOT_DIR, "ext")
  BDWGC_DIR = File.join(EXT_DIR, "bdwgc", BDWGC_VERSION, OS)
  BDWGC_BUILD_DIR = File.join(BDWGC_DIR, "build")
  BDWGC_LIB_DIR = File.join(BDWGC_DIR, "lib")
  VERSIONS_DIR = File.join(ROOT_DIR, "versions", OS)
  LAST_DIR = File.join(ROOT_DIR, "last")
  LAST_VERSION = File.join(LAST_DIR, OS)

  def single_run(*args, chdir: nil)
    if chdir
      Dir.chdir(chdir) do
        single_run *args
      end
    else
      abort "Command error: #{args}" unless system(*args)
    end
  end

  def run(*args, chdir: nil)
    env = args.first.is_a?(Hash) ? args.shift : {}
    cmds = args.shift
    cmds = [cmds] unless cmds.is_a?(Array)
    cmds.each do |i|
      i = i.gsub("\\\n\s+", "")
      i.chomp.split("\n").each do |j|
        single_run env, j, *args, chdir: chdir
      end
    end
  end

  def sh(*args)
    output, status = Open3.capture2(*args)
    raise "Command error: #{args}" unless status.success?
    output
  end

  def build_bdwgc(force: false)
    return if !force && Dir.exist?(BDWGC_LIB_DIR)
    run "rm -rf #{BDWGC_DIR}"
    run "git clone --depth=1 -b gc#{BDWGC_VERSION} https://github.com/ivmai/bdwgc.git #{BDWGC_BUILD_DIR}"
    run "git clone --depth=1 -b libatomic_ops-#{LIBATOMIC_OPS_VERSION} https://github.com/ivmai/libatomic_ops.git #{BDWGC_BUILD_DIR}/libatomic_ops"
    Dir.chdir(BDWGC_BUILD_DIR) do
      env = {}
      run env, <<~EOS
      autoreconf -vif
      automake --add-missing
      ./configure --prefix=#{BDWGC_DIR} --exec-prefix=#{BDWGC_DIR}
      make
      make check
      make install
      EOS
    end
  end

  def time
    @time ||= Time.now.utc
  end

  def time_string
    @time_string ||= time.strftime("%Y%m%d%H%M%S")
  end

  def version_string
    @version_string ||= "#{time_string}-#{ref}-#{commit}"
  end

  def version_name
    @version_name ||= ENV["CRYSTAL_EDGE_VERSION_NAME"] || "edge"
  end

  def build_dir
    @build_dir ||= File.join(VERSIONS_DIR, version_string)
  end

  def ref
    @ref ||= ENV["CRYSTAL_EDGE_REF"] || "master"
  end

  def config_version
    ref if /^(\d+\.){0,2}\d+$/ =~ ref
  end

  def last_dir
    @last_dir ||= begin
      dir = sh("readlink #{LAST_VERSION}").chomp
      abort "Not built yet." if dir.empty?
      dir
    end
  end

  def commit
    @commit ||= begin
      line = sh("git ls-remote #{CRYSTAL_GIT_URL} #{ref}").split("\n")[0].to_s
      abort "Can't find commit from ref: #{ref}" if line.empty?
      line.split(/\s+/)[0]
    end
  end

  def build
    config_version
    FileUtils.mkdir_p build_dir
    if linux?
      # build_bdwgc
    end
    Dir.chdir(build_dir) do
      run "git init"
      run "git remote add origin #{CRYSTAL_GIT_URL}"
      run "git fetch origin #{ref}"
      run "git checkout #{commit}"
      env = {}
      env["CRYSTAL_CONFIG_VERSION"] ||= config_version
      run env, "make stats=1 verbose=1"
    end
    FileUtils.mkdir_p File.dirname(LAST_VERSION)
    run "ln -nfs #{build_dir} #{LAST_VERSION}"
    puts "#{LAST_VERSION} -> #{last_dir}"
  end

  def crenv_install
    crenv = sh("which crenv").chomp
    abort "No crenv is installed." if crenv.empty?
    versions = File.expand_path(File.join("..", "..", "versions"), crenv)
    abort "No versions directory." unless Dir.exist?(versions)
    to = File.join(versions, version_name)
    run "ln -nfs #{last_dir} #{to}"
    puts to
  end
end

def build(&block)
  Build.class_eval &block
end

namespace :build do
  task :release do
    build do
      build
    end
  end
end
task :build => ["build:release"]

namespace :crenv do
  task :install do
    build do
      crenv_install
    end
  end
end
