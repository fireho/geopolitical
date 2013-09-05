Fabricator :region do
  name { Faker::Address.city }
  abbr { |p| p[:name][0..2].upcase }
  nation
end
