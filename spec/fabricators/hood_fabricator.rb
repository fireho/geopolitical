Fabricator :hood do
  city
  name  { sequence(:name) { |i| "#{Faker::Address.city}#{i}" }}
  geom  { [rand(30) - 50, rand(40) - 30] }
  #code { object.name[0..2].upcase }
end
