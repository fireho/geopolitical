Fabricator :address do
  nation
  city
  title  { Faker::Address.street_name }
  number { rand(5000) }
  zip    { Faker::Address.zip_code }
  # geom  { [rand(30) - 50, rand(40) - 30] }
  #code { object.name[0..2].upcase }
end
