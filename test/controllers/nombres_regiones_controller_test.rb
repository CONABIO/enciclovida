require 'test_helper'

class NombresRegionesControllerTest < ActionController::TestCase
  setup do
    @nombr_regione = nombres_regiones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nombres_regiones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nombr_regione" do
    assert_difference('NombreRegion.count') do
      post :create, nombr_regione: {  }
    end

    assert_redirected_to nombr_regione_path(assigns(:nombr_regione))
  end

  test "should show nombr_regione" do
    get :show, id: @nombr_regione
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nombr_regione
    assert_response :success
  end

  test "should update nombr_regione" do
    patch :update, id: @nombr_regione, nombr_regione: {  }
    assert_redirected_to nombr_regione_path(assigns(:nombr_regione))
  end

  test "should destroy nombr_regione" do
    assert_difference('NombreRegion.count', -1) do
      delete :destroy, id: @nombr_regione
    end

    assert_redirected_to nombres_regiones_path
  end
end
