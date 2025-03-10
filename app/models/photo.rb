class Photo

  attr_accessor :api_response, :id, :usuario_id, :native_photo_id, :square_url, :thumb_url, :small_url, :medium_url, :large_url, :original_url, :created_at, :updated_at, :native_page_url, :native_username, :native_realname, :license, :type, :file_content_type, :file_file_name, :file_file_size, :file_processing, :mobile, :file_updated_at, :metadata, :attribution_txt

  def best_photo
    if original_url.present?
      original_url
    elsif medium_url.present?
      medium_url
    elsif large_url.present?
      large_url
    else
      nil
    end
  end

end
