require 'test_helper'

class NombreRegionesBibliografiasControllerTest < ActionController::TestCase
  setup do
    @nombre_region_bibliografia = nombre_regiones_bibliografias(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nombre_regiones_bibliografias)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nombre_region_bibliografia" do
    assert_difference('NombreRegionBibliografia.count') do
      post :create, nombre_region_bibliografia: {  }
    end

    assert_redirected_to nombre_region_bibliografia_path(assigns(:nombre_region_bibliografia))
  end

  test "should show nombre_region_bibliografia" do
    get :show, id: @nombre_region_bibliografia
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nombre_region_bibliografia
    assert_response :success
  end

  test "should update nombre_region_bibliografia" do
    patch :update, id: @nombre_region_bibliografia, nombre_region_bibliografia: {  }
    assert_redirected_to nombre_region_bibliografia_path(assigns(:nombre_region_bibliografia))
  end

  test "should destroy nombre_region_bibliografia" do
    assert_difference('NombreRegionBibliografia.count', -1) do
      delete :destroy, id: @nombre_region_bibliografia
    end

    assert_redirected_to nombre_regiones_bibliografias_path
  end
end
