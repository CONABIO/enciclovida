require 'test_helper'

class TiposDistribucionesControllerTest < ActionController::TestCase
  setup do
    @tipo_distribucion = tipos_distribuciones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tipos_distribuciones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tipo_distribucion" do
    assert_difference('TipoDistribucion.count') do
      post :create, tipo_distribucion: {  }
    end

    assert_redirected_to tipo_distribucion_path(assigns(:tipo_distribucion))
  end

  test "should show tipo_distribucion" do
    get :show, id: @tipo_distribucion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tipo_distribucion
    assert_response :success
  end

  test "should update tipo_distribucion" do
    patch :update, id: @tipo_distribucion, tipo_distribucion: {  }
    assert_redirected_to tipo_distribucion_path(assigns(:tipo_distribucion))
  end

  test "should destroy tipo_distribucion" do
    assert_difference('TipoDistribucion.count', -1) do
      delete :destroy, id: @tipo_distribucion
    end

    assert_redirected_to tipos_distribuciones_path
  end
end
