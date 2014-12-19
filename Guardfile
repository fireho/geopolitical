# A sample Guardfile
# More info at https://github.com/guard/guard#readme
# ignore(/\/.#.+/)

guard :rubocop, all_on_start: false, keep_failed: false, notification: false, cli: ['--format', 'emacs'] do
  watch(/^lib\/(.+)\.rb$/)
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^spec\/spec_helper\.rb$/) { 'spec' }
  watch(/^app\/(.+)\.rb$/)         { |m| "spec/#{m[1]}_spec.rb" }
  watch(/^lib\/(.+)\.rb$/)         { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/models/concerns/(.+)\.rb$})  { |m| "spec/models/*._spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  do |m|
    [
      "spec/routing/#{m[1]}_routing_spec.rb",
      "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
      "spec/requests/#{m[1]}_spec.rb"
    ]
  end
end
