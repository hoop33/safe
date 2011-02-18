require 'rake/testtask'
require 'rake/gempackagetask'

gem_spec = Gem::Specification.new do |spec|
  # Program information
  spec.name = 'safe'
  spec.summary = 'A command-line password storage program'
  spec.description = %{safe safely stores all your user IDs and passwords,
  encrypted by a password of your choosing.}
  spec.version = '0.7'
  
  # Author information
  spec.author = 'Rob Warner'
  spec.email = 'rwarner@grailbox.com'
  spec.homepage = 'http://safe.rubyforge.org/'
  spec.rubyforge_project = 'safe'
  
  # Files
  spec.test_files = FileList['test/**/*']
  spec.bindir = 'bin'
  spec.executables = ['safe']
  spec.default_executable = 'safe'
  spec.files = FileList['README', 'lib/**/*.rb', 'index.html', 'Rakefile',
                        'README', 'Release-Notes.txt']

  # Dependencies
  spec.add_dependency('crypt', '>= 1.1.4')
  spec.add_dependency('highline', '>= 1.4.0')
end

Rake::TestTask.new('test') do |t|
  t.pattern = 'test/**/tc_*.rb'
  t.warning = true
end

Rake::GemPackageTask.new(gem_spec) do |pkg|
end

task :web do
  # Read in the HTML template
  f = File.open "index.html"
  html = f.read
  f.close
  
  # Read in the readme
  f = File.open "README"
  readme = f.read
  f.close

  # Transform as necessary
  readme.gsub!(/</, '&lt;')
  readme.gsub!(/>/, '&gt;')
  readme.gsub!(/===(.*?)===/, '<h1>\1</h1>')
  readme.gsub!(/==(.*?)==/, '<h2>\1</h2>')
  readme.gsub!(/\n/, '<br />')
  html.sub!("<!-- Insert your content here -->", readme) 
  
  # Output the HTML
  f = File.open "pkg/index.html", "w"
  f.puts html
  f.close
end
