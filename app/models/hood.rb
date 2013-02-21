class Hood
  include Mongoid::Document

  field :name,  type: String
  field :souls, type: Integer
  field :slug,  type: String
  field :zip,   type: Integer
  field :rank,  type: Integer

  belongs_to :city
  validates  :city, :name, presence: true

  def to_param
    "#{id}-#{name}"
  end

end
