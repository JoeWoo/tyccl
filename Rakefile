require "bundler/gem_tasks"
begin
	require "rake/rdoctask"
rescue Exception => e
	require "rdoc/task"
end
Rake::RDocTask.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("*.md", "lib/tyccl.rb")
  rd.rdoc_dir = "doc"
end
