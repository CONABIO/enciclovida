require 'test_helper'

class BusquedasControllerTest < ActionController::TestCase
  test "should get basica" do
    get :basica
    assert_response :success
  end

  test "should get avanzada" do
    get :avanzada
    assert_response :success
  end

  test "should get resultados" do
    get :resultados
    assert_response :success
  end

end
