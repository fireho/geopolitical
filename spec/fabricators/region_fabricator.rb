Fabricator :region do
  nation
  name { Faker::Address.city }
  abbr { |p| p[:name][0..2].upcase }
end
