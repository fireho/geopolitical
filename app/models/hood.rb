class Hood
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :souls, type: Integer
  field :zip,   type: Integer
  field :rank,  type: Integer
  field :zip,   type: Integer

  belongs_to :city, index: true

  validates :name, :city, presence: true

  def self.search(search, page)
    cities = search ? where(:field => /#{search}/i) : all
    cities.page(page)
  end

  def to_param
    "#{id}-#{name}"
  end
end
