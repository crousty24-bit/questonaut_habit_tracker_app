namespace :sass do
  desc "Compile application.scss → app/assets/builds/sass.css"
  task :build do
    sh "bundle exec sass " \
      "app/assets/stylesheets/application.scss " \
      "app/assets/builds/sass.css " \
      "--load-path app/assets/stylesheets " \
      "--style compressed --no-source-map"
  end

  desc "Watch Sass and recompile on change"
  task :watch do
    sh "bundle exec sass " \
      "app/assets/stylesheets/application.scss:app/assets/builds/sass.css " \
      "--load-path app/assets/stylesheets " \
      "--watch"
  end
end

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["sass:build"])
end