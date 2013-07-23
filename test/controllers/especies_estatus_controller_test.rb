require 'test_helper'

class EspeciesEstatusControllerTest < ActionController::TestCase
  setup do
    @especie_estatus = especies_estatus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:especies_estatus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create especie_estatus" do
    assert_difference('EspecieEstatus.count') do
      post :create, especie_estatus: {  }
    end

    assert_redirected_to especie_estatus_path(assigns(:especie_estatus))
  end

  test "should show especie_estatus" do
    get :show, id: @especie_estatus
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @especie_estatus
    assert_response :success
  end

  test "should update especie_estatus" do
    patch :update, id: @especie_estatus, especie_estatus: {  }
    assert_redirected_to especie_estatus_path(assigns(:especie_estatus))
  end

  test "should destroy especie_estatus" do
    assert_difference('EspecieEstatus.count', -1) do
      delete :destroy, id: @especie_estatus
    end

    assert_redirected_to especies_estatus_path
  end
end
