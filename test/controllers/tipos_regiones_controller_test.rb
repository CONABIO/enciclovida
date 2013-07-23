require 'test_helper'

class TiposRegionesControllerTest < ActionController::TestCase
  setup do
    @tipo_region = tipos_regiones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tipos_regiones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tipo_region" do
    assert_difference('TipoRegion.count') do
      post :create, tipo_region: {  }
    end

    assert_redirected_to tipo_region_path(assigns(:tipo_region))
  end

  test "should show tipo_region" do
    get :show, id: @tipo_region
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tipo_region
    assert_response :success
  end

  test "should update tipo_region" do
    patch :update, id: @tipo_region, tipo_region: {  }
    assert_redirected_to tipo_region_path(assigns(:tipo_region))
  end

  test "should destroy tipo_region" do
    assert_difference('TipoRegion.count', -1) do
      delete :destroy, id: @tipo_region
    end

    assert_redirected_to tipos_regiones_path
  end
end
