require 'test_helper'

class InicioControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get comentarios" do
    get :comentarios
    assert_response :success
  end

  test "should get acerca" do
    get :acerca
    assert_response :success
  end

  test "should get terminos" do
    get :terminos
    assert_response :success
  end

  test "should get ayuda" do
    get :ayuda
    assert_response :success
  end

end
