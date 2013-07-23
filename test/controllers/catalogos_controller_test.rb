require 'test_helper'

class CatalogosControllerTest < ActionController::TestCase
  setup do
    @catalogo = catalogos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:catalogos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create catalogo" do
    assert_difference('Catalogo.count') do
      post :create, catalogo: {  }
    end

    assert_redirected_to catalogo_path(assigns(:catalogo))
  end

  test "should show catalogo" do
    get :show, id: @catalogo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @catalogo
    assert_response :success
  end

  test "should update catalogo" do
    patch :update, id: @catalogo, catalogo: {  }
    assert_redirected_to catalogo_path(assigns(:catalogo))
  end

  test "should destroy catalogo" do
    assert_difference('Catalogo.count', -1) do
      delete :destroy, id: @catalogo
    end

    assert_redirected_to catalogos_path
  end
end
