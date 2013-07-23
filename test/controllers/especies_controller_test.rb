require 'test_helper'

class EspeciesControllerTest < ActionController::TestCase
  setup do
    @especie = especies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:especies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create especie" do
    assert_difference('Especie.count') do
      post :create, especie: {  }
    end

    assert_redirected_to especie_path(assigns(:especie))
  end

  test "should show especie" do
    get :show, id: @especie
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @especie
    assert_response :success
  end

  test "should update especie" do
    patch :update, id: @especie, especie: {  }
    assert_redirected_to especie_path(assigns(:especie))
  end

  test "should destroy especie" do
    assert_difference('Especie.count', -1) do
      delete :destroy, id: @especie
    end

    assert_redirected_to especies_path
  end
end
