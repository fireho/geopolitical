class ZoneMember
  include Mongoid::Document

  belongs_to :zone
  belongs_to :member, polymorphic: true



end
