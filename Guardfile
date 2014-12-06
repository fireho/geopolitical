# A sample Guardfile
# More info at https://github.com/guard/guard#readme
# ignore(/\/.#.+/)

guard :rubocop, all_on_start: false, keep_failed: false, notification: false, cli: ['--format', 'emacs'] do
  watch(/^lib\/(.+)\.rb$/)
end

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end
