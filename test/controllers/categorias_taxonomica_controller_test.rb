require 'test_helper'

class CategoriasTaxonomicaControllerTest < ActionController::TestCase
  setup do
    @categoria_taxonomica = categorias_taxonomica(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categorias_taxonomica)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create categoria_taxonomica" do
    assert_difference('CategoriaTaxonomica.count') do
      post :create, categoria_taxonomica: {  }
    end

    assert_redirected_to categoria_taxonomica_path(assigns(:categoria_taxonomica))
  end

  test "should show categoria_taxonomica" do
    get :show, id: @categoria_taxonomica
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @categoria_taxonomica
    assert_response :success
  end

  test "should update categoria_taxonomica" do
    patch :update, id: @categoria_taxonomica, categoria_taxonomica: {  }
    assert_redirected_to categoria_taxonomica_path(assigns(:categoria_taxonomica))
  end

  test "should destroy categoria_taxonomica" do
    assert_difference('CategoriaTaxonomica.count', -1) do
      delete :destroy, id: @categoria_taxonomica
    end

    assert_redirected_to categorias_taxonomica_path
  end
end
