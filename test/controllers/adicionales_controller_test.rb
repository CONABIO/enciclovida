require 'test_helper'

class AdicionalesControllerTest < ActionController::TestCase
  setup do
    @adicional = adicionales(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:adicionales)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create adicional" do
    assert_difference('Adicional.count') do
      post :create, adicional: {  }
    end

    assert_redirected_to adicional_path(assigns(:adicional))
  end

  test "should show adicional" do
    get :show, id: @adicional
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @adicional
    assert_response :success
  end

  test "should update adicional" do
    patch :update, id: @adicional, adicional: {  }
    assert_redirected_to adicional_path(assigns(:adicional))
  end

  test "should destroy adicional" do
    assert_difference('Adicional.count', -1) do
      delete :destroy, id: @adicional
    end

    assert_redirected_to adicionales_path
  end
end
