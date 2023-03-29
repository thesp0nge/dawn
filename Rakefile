require "bundler/gem_tasks"
require "rspec/core/rake_task"
# require "highline/import"

require 'cucumber'
require 'cucumber/rake/task'

require 'fileutils'
require "dawn/utils"
require "dawn/knowledge_base"

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty -x"
  t.fork = false
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--color"]
end


task :default => [ :spec, :features, :'kb:create', :'kb:lint' ]
task :test => :spec
task :prepare => [:build, :'checksum:calculate', :'checksum:commit']
task :release => [:prepare]

namespace :version do
  desc 'Calculate some infos you want to put in version.rb'
  task :update do
    build_number  = `git describe --tags --long | cut -d \'-\' -f 2`
    commit_hash   = `git describe --tags --long | cut -d \'-\' -f 3`
    release       = Time.now.strftime("%Y%m%d")
    branch        = `git symbolic-ref HEAD 2> /dev/null`
    branch_name   = branch.split('/')[2].chomp
    a=[]
    File.open("VERSION", "r") do |f|
      a = f.readlines
    end
    version = a[a.length - 1].split('-')[0]# .chomp

    File.open("./lib/dawn/version.rb", "w") do |f|

      f.puts("module Dawn")

      puts "#{branch_name}|"
      if branch_name != "main"
        av = version.split('.')
        f.puts "    VERSION = \"#{av[0]}.#{av[1]}.#{commit_hash.chop}\""
        f.puts "    RELEASE = \"(development)\""
      else
        f.puts "    VERSION = \"#{version.rstrip!}\""
        f.puts "    RELEASE = \"#{release}\""
      end
      f.puts "    BUILD = \"#{build_number.chop}\""
      f.puts "    COMMIT = \"#{commit_hash.chop}\""
      f.puts "end"
    end
  end
end

namespace :kb do
  desc 'Check information lint'
  task :lint do
    Dawn::KnowledgeBase.new.all.each do |check|
      l = check.lint
      puts "check #{check.name} has this attribute(s) with a nil value: #{l.to_s}" unless l.size == 0
    end

  end
  desc 'Pack the library for shipping'

  task :pack do
    YAML_KB = File.join(Dir.home, "dawnscanner", 'db')
    FileUtils.mkdir_p(YAML_KB)
    __kb_pack
  end

  desc 'Creates a KnowledgeBase.md file'
  task :create do
    checks = Dawn::KnowledgeBase.new.all
    open("KnowledgeBase.md", "w") do |file|
      file.puts "# Dawnscanner Knowledge base"
      file.puts "\nThe knowledge base library for dawnscanner version #{Dawn::VERSION} contains #{checks.count} security checks."
      file.puts "---"
      checks.each do |c|
        file.puts "* [#{c.name}](#{c.cve_link}): #{c.message}" if c.name.start_with?('CVE')
        file.puts "* [#{c.name}](#{c.osvdb_link}): #{c.message}" if c.name.start_with?('OSVDB')
        file.puts "* #{c.name}: #{c.message}" unless c.name.start_with?('CVE') && c.name.start_with?('OSVDB')
      end

      file.puts "\n\n_Last updated: #{Time.now.strftime("%a %d %b %T %Z %Y")}_"
    end
    puts "KnowledgeBase.md file successfully generated"

  end
end

require 'digest/sha1'
namespace :checksum do

desc 'Calculate gem checksum'
task :calculate do
  system 'mkdir -p checksum > /dev/null'
  built_gem_path = "pkg/dawnscanner-#{Dawn::VERSION}.gem"
  checksum = Digest::SHA1.new.hexdigest(File.read(built_gem_path))
  checksum_path = "checksum/dawnscanner-#{Dawn::VERSION}.gem.sha1"
  File.open(checksum_path, 'w' ) {|f| f.write(checksum) }

  puts "#{checksum_path}: #{checksum}"
end

desc 'Add and commit latest checksum'
task :commit do
  checksum_path = "checksum/dawnscanner-#{Dawn::VERSION}.gem.sha1"
  system "git add #{checksum_path}"
  system "git commit -v #{checksum_path} -m \"Adding #{Dawn::VERSION} checksum to repo\""
end
end

###############################################################################
# ruby-advisory-rb integration
###############################################################################

namespace :rubysec do
  desc 'Find new CVE bulletins to add to Dawn'
  task :find do
    git_url = 'git@github.com:rubysec/ruby-advisory-db.git'
    target_dir = './tmp/'
    system "mkdir -p #{target_dir}"
    system "rm -rf #{target_dir}ruby-advisory-db"
    system "git clone #{git_url} #{target_dir}ruby-advisory-db"
    list = []
    Dir.glob("#{target_dir}ruby-advisory-db/gems/*/*.yml") do |path|
      advisory = YAML.load_file(path)
      if advisory['cve']
        cve = "CVE-"+advisory['cve']
        # Exclusion
        # CVE-2007-6183 is a vulnerability in gnome2 ruby binding. Not a gem, I don't care
        # CVE-2013-1878 is a duplicate of CVE-2013-2617 that is in knowledge base
        # CVE-2013-1876 is a duplicate of CVE-2013-2615 that is in knowledge base
        exclusion = ["CVE-2007-6183", "CVE-2013-1876", "CVE-2013-1878"]
        if exclusion.include?(cve)
          puts "#{cve} is in the exclusion list"
        else
          found = Dawn::KnowledgeBase.find(nil, cve)
          puts "#{cve} NOT in dawn v#{Dawn::VERSION} knowledge base" unless found
          list << cve unless found
        end
      end
    end
    unless list.empty?
      File.open("missing_rubyadvisory_cvs_#{Time.now.strftime("%Y%m%d")}.txt", "w") do |f|
        f.puts "Missing CVE bulletins - v#{Dawn::VERSION} - #{Time.now.strftime("%d %B %Y")}"
        f.puts list
      end
    end
    system "rm -rf #{target_dir}ruby-advisory-db"

  end
end

def __kb_pack
  if Dir.exists? "#{YAML_KB}/bulletin"
    system "tar cfvz #{YAML_KB}/bulletin.tar.gz -C #{YAML_KB} bulletin"
    system "rm -rf #{YAML_KB}/bulletin"
    system "shasum -a 256 #{YAML_KB}/bulletin.tar.gz > #{YAML_KB}/bulletin.tar.gz.sig"
  end

  if Dir.exists? "#{YAML_KB}/generic_check"
    system "tar cfvz #{YAML_KB}/generic_check.tar.gz -C #{YAML_KB} generic_check"
    system "rm -rf #{YAML_KB}/generic_check"
    system "shasum -a 256 #{YAML_KB}/generic_check.tar.gz > #{YAML_KB}/generic_check.tar.gz.sig"
  end

  if Dir.exists? "#{YAML_KB}/owasp_ror_cheatsheet"
    system "tar cfvz #{YAML_KB}/owasp_ror_cheatsheet.tar.gz -C #{YAML_KB} owasp_ror_cheatsheet"
    system "rm -rf #{YAML_KB}/owasp_ror_cheatsheet"
    system "shasum -a 256 #{YAML_KB}/owasp_ror_cheatsheet.tar.gz > #{YAML_KB}/owasp_ror_cheatsheet.tar.gz.sig"
  end

  if Dir.exists? "#{YAML_KB}/code_style"
    system "tar cfvz #{YAML_KB}/code_style.tar.gz -C #{YAML_KB} code_style"
    system "rm -rf #{YAML_KB}/code_style"
    system "shasum -a 256 #{YAML_KB}/code_style.tar.gz > #{YAML_KB}/code_style.tar.gz.sig"
  end
  if Dir.exists? "#{YAML_KB}/code_quality"
    system "tar cfvz #{YAML_KB}/code_quality.tar.gz -C #{YAML_KB} code_quality"
    system "rm -rf #{YAML_KB}/code_quality"
    system "shasum -a 256 #{YAML_KB}/code_quality.tar.gz > #{YAML_KB}/code_quality.tar.gz.sig"
  end
  if Dir.exists? "#{YAML_KB}/owasp_top_10"
    system "tar cfvz #{YAML_KB}/owasp_top_10.tar.gz -C #{YAML_KB} owasp_top_10"
    system "rm -rf #{YAML_KB}/owasp_top_10"
    system "shasum -a 256 #{YAML_KB}/owasp_top_10.tar.gz > #{YAML_KB}/owasp_top_10.tar.gz.sig"
  end


  open(File.join(YAML_KB, "kb.yaml"), 'w') do |f|
    f.puts(Dawn::KnowledgeBase.kb_descriptor)
  end
  puts "kb.yaml created"
  system "shasum -a 256 #{YAML_KB}/kb.yaml > #{YAML_KB}/kb.yaml.sig"

  puts "Library ready to be shipped"

end
