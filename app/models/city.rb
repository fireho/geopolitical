#
# Cities
#
class City
  include Mongoid::Document
  include Mongoid::Geospatial
  include Geopolitocracy

  field :area,    type: Integer # m2 square area
  field :geom,    type: Point, spatial: true
  field :rbbr,    type: String, as: :region_abbr

  spatial_scope :geom

  belongs_to :region, inverse_of: :cities, optional: true
  belongs_to :nation, inverse_of: :cities
  has_many :hoods

  has_one :nation_governancy, as: :nation_capital, class_name: 'Nation'
  has_one :region_governancy, as: :region_capital, class_name: 'Region'

  before_validation :ensure_derived_fields_and_slug

  validates :name, uniqueness: { scope: :region_id }
  validate :region_inside_nation

  scope :population, -> { order_by(pop: -1) }

  index({ slug: 1 }, unique: true)
  index({ name: 1, nation_id: 1 })
  index({ nation_id: 1 })
  index({ region_id: 1 }, sparse: true)
  index({ pop: -1 })

  def region_inside_nation
    return if !region || region.nation == nation

    errors.add(:region, 'not inside Nation')
  end

  # Custom getter for region_abbr that populates rbbr if needed
  def region_abbr
    val = read_attribute(:rbbr)
    if val.blank? && region
      val = region.abbr.presence || region.name.presence
      write_attribute(:rbbr, val) # Store it for future use and for callbacks
    end
    val
  end

  def ensure_derived_fields_and_slug
    # Ensure nation is derived from region if not set and region exists
    if region
      self.nation ||= region.nation
      write_attribute(:rbbr, region.abbr.presence || region.name.presence) if read_attribute(:rbbr).blank?
    end
    current_rbbr = read_attribute(:rbbr) # Use the potentially just-set rbbr

    # Geopolitocracy's ensure_slug runs before_validation, typically setting slug ||= name.
    # We need to append our suffix to that.
    # The Geopolitocracy concern should have already set a base slug (e.g., from name).
    return unless current_rbbr.present? && slug.present?

    slug_suffix = "-#{current_rbbr}"
    # Only append if the slug doesn't already end with this specific suffix.
    # This handles cases where slug might be `name-rbbr` already or just `name`.
    return if slug.end_with?(slug_suffix)

    # If the slug is just the name (common after Geopolitocracy's ensure_slug),
    # or if it's some other base slug that doesn't include our suffix.
    self.slug += slug_suffix
  end

  def phone
    self[:phone] || region.phone || nation.phone
  end

  def phones
    hoods.map(&:phone)
  end

  def postal
    self[:postal] || region.postal || nation.postal
  end

  def postals
    hoods.map(&:postal)
  end

  def ==(other)
    return unless other.is_a?(City)

    other && slug == other.slug
  end

  def <=>(other)
    return unless other.is_a?(City)

    slug <=> other.slug
  end

  def with_region(separator = '/')
    return name unless region_abbr

    "#{name}#{separator}#{region_abbr}"
  end

  def with_nation(separator = '/')
    with_region(separator) + "#{separator}#{nation.abbr}"
  end

  def to_s
    with_region
  end
end
