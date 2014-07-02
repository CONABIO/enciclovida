class TaxonPhoto < ActiveRecord::Base
  self.table_name = :taxon_photos
  belongs_to :especie
  belongs_to :photo
  
  after_create :expire_caches
  after_destroy :destroy_orphan_photo
  after_destroy :unfeature_taxon
  after_destroy :expire_caches
  
  validates_associated :photo
  validates_uniqueness_of :photo_id, :scope => [:especie_id], :message => "has already been added to that taxon"
  
  def destroy_orphan_photo
    Photo.delay(:priority => INTEGRITY_PRIORITY).destroy_orphans(photo_id)
    true
  end
  
  def unfeature_taxon
    return true if taxon.featured_at.blank?
    taxon.update_attribute(:featured_at, nil) if taxon.taxon_photos.count == 0
    true
  end
  
  def expire_caches
    Rails.cache.delete(especie.photos_cache_key)
    Rails.cache.delete(especie.photos_with_external_cache_key)
    true
  end
  
end
