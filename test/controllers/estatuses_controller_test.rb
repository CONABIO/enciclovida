require 'test_helper'

class EstatusesControllerTest < ActionController::TestCase
  setup do
    @estatuse = estatuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:estatuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create estatuse" do
    assert_difference('Estatus.count') do
      post :create, estatuse: {  }
    end

    assert_redirected_to estatuse_path(assigns(:estatuse))
  end

  test "should show estatuse" do
    get :show, id: @estatuse
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @estatuse
    assert_response :success
  end

  test "should update estatuse" do
    patch :update, id: @estatuse, estatuse: {  }
    assert_redirected_to estatuse_path(assigns(:estatuse))
  end

  test "should destroy estatuse" do
    assert_difference('Estatus.count', -1) do
      delete :destroy, id: @estatuse
    end

    assert_redirected_to estatuses_path
  end
end
