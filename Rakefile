task :default do
  sh 'rspec spec'
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/deleft.zip autoload/ doc/deleft.txt plugin/'
end
