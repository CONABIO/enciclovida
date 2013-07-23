require 'test_helper'

class EspeciesBibliografiaControllerTest < ActionController::TestCase
  setup do
    @especie_bibliografia = especies_bibliografia(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:especies_bibliografia)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create especie_bibliografia" do
    assert_difference('EspecieBibliografia.count') do
      post :create, especie_bibliografia: {  }
    end

    assert_redirected_to especie_bibliografia_path(assigns(:especie_bibliografia))
  end

  test "should show especie_bibliografia" do
    get :show, id: @especie_bibliografia
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @especie_bibliografia
    assert_response :success
  end

  test "should update especie_bibliografia" do
    patch :update, id: @especie_bibliografia, especie_bibliografia: {  }
    assert_redirected_to especie_bibliografia_path(assigns(:especie_bibliografia))
  end

  test "should destroy especie_bibliografia" do
    assert_difference('EspecieBibliografia.count', -1) do
      delete :destroy, id: @especie_bibliografia
    end

    assert_redirected_to especies_bibliografia_path
  end
end
