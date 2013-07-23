require 'test_helper'

class EspeciesEstatusBibliografiaControllerTest < ActionController::TestCase
  setup do
    @especie_estatus_bibliografia = especies_estatus_bibliografia(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:especies_estatus_bibliografia)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create especie_estatus_bibliografia" do
    assert_difference('EspecieEstatusBibliografia.count') do
      post :create, especie_estatus_bibliografia: {  }
    end

    assert_redirected_to especie_estatus_bibliografia_path(assigns(:especie_estatus_bibliografia))
  end

  test "should show especie_estatus_bibliografia" do
    get :show, id: @especie_estatus_bibliografia
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @especie_estatus_bibliografia
    assert_response :success
  end

  test "should update especie_estatus_bibliografia" do
    patch :update, id: @especie_estatus_bibliografia, especie_estatus_bibliografia: {  }
    assert_redirected_to especie_estatus_bibliografia_path(assigns(:especie_estatus_bibliografia))
  end

  test "should destroy especie_estatus_bibliografia" do
    assert_difference('EspecieEstatusBibliografia.count', -1) do
      delete :destroy, id: @especie_estatus_bibliografia
    end

    assert_redirected_to especies_estatus_bibliografia_path
  end
end
