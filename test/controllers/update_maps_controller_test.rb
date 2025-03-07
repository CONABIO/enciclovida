require 'test_helper'

class UpdateMapsControllerTest < ActionDispatch::IntegrationTest
  test "should get upload" do
    get update_maps_upload_url
    assert_response :success
  end

end
