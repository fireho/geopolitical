Fabricator :nation do
  name { sequence { |_i| Faker::Address.country } }
  abbr { |c| c[:name].first.upcase + ('A'..'Z').to_a[rand(23)] }
end
