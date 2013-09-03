class Hood
  include Mongoid::Document

  field :gid,   type: Integer
  field :slug,  type: String
  field :name,  type: String, localize: true
  field :souls, type: Integer
  field :zip,   type: Integer
  field :rank,  type: Integer

  belongs_to :city
  validates  :city, :name, presence: true

  def to_param
    "#{id}-#{name}"
  end

end
