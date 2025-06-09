Fabricator :city do
  nation
  name  { sequence(:name) { |i| "#{Faker::Address.city}#{i}" } }
  geom  { [rand(-50..-21), rand(-30..9)] }
  # code { object.name[0..2].upcase }
end
