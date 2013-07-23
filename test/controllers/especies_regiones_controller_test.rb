require 'test_helper'

class EspeciesRegionesControllerTest < ActionController::TestCase
  setup do
    @especie_region = especies_regiones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:especies_regiones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create especie_region" do
    assert_difference('EspecieRegion.count') do
      post :create, especie_region: {  }
    end

    assert_redirected_to especie_region_path(assigns(:especie_region))
  end

  test "should show especie_region" do
    get :show, id: @especie_region
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @especie_region
    assert_response :success
  end

  test "should update especie_region" do
    patch :update, id: @especie_region, especie_region: {  }
    assert_redirected_to especie_region_path(assigns(:especie_region))
  end

  test "should destroy especie_region" do
    assert_difference('EspecieRegion.count', -1) do
      delete :destroy, id: @especie_region
    end

    assert_redirected_to especies_regiones_path
  end
end
