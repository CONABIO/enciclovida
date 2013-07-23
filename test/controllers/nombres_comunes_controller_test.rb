require 'test_helper'

class NombresComunesControllerTest < ActionController::TestCase
  setup do
    @nombr_comune = nombres_comunes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nombres_comunes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nombr_comune" do
    assert_difference('NombreComun.count') do
      post :create, nombr_comune: {  }
    end

    assert_redirected_to nombr_comune_path(assigns(:nombr_comune))
  end

  test "should show nombr_comune" do
    get :show, id: @nombr_comune
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nombr_comune
    assert_response :success
  end

  test "should update nombr_comune" do
    patch :update, id: @nombr_comune, nombr_comune: {  }
    assert_redirected_to nombr_comune_path(assigns(:nombr_comune))
  end

  test "should destroy nombr_comune" do
    assert_difference('NombreComun.count', -1) do
      delete :destroy, id: @nombr_comune
    end

    assert_redirected_to nombres_comunes_path
  end
end
