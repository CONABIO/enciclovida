require 'test_helper'

class EspeciesCatalogoControllerTest < ActionController::TestCase
  setup do
    @especie_catalogo = especies_catalogo(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:especies_catalogo)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create especie_catalogo" do
    assert_difference('EspecieCatalogo.count') do
      post :create, especie_catalogo: {  }
    end

    assert_redirected_to especie_catalogo_path(assigns(:especie_catalogo))
  end

  test "should show especie_catalogo" do
    get :show, id: @especie_catalogo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @especie_catalogo
    assert_response :success
  end

  test "should update especie_catalogo" do
    patch :update, id: @especie_catalogo, especie_catalogo: {  }
    assert_redirected_to especie_catalogo_path(assigns(:especie_catalogo))
  end

  test "should destroy especie_catalogo" do
    assert_difference('EspecieCatalogo.count', -1) do
      delete :destroy, id: @especie_catalogo
    end

    assert_redirected_to especies_catalogo_path
  end
end
