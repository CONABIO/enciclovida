require 'test_helper'

class BitacorasControllerTest < ActionController::TestCase
  setup do
    @bitacora = bitacoras(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bitacoras)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bitacora" do
    assert_difference('Bitacora.count') do
      post :create, bitacora: {  }
    end

    assert_redirected_to bitacora_path(assigns(:bitacora))
  end

  test "should show bitacora" do
    get :show, id: @bitacora
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bitacora
    assert_response :success
  end

  test "should update bitacora" do
    patch :update, id: @bitacora, bitacora: {  }
    assert_redirected_to bitacora_path(assigns(:bitacora))
  end

  test "should destroy bitacora" do
    assert_difference('Bitacora.count', -1) do
      delete :destroy, id: @bitacora
    end

    assert_redirected_to bitacoras_path
  end
end
