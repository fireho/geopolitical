module Geopolitical
  module Helpers
    extend ActiveSupport::Concern

    included do
      before_validation :set_slug
    end

    def to_s
      name || slug
    end

    def set_slug
      self.slug ||= name
    end

    def slug= txt
      return unless txt
      self[:slug] = txt.downcase.gsub(/\s/, '-') #.gsub(/\W/, '')
    end
  end
end
