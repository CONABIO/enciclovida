require 'test_helper'

class RolesCategoriasContenidoControllerTest < ActionController::TestCase
  setup do
    @rol_categorias_contenido = roles_categorias_contenido(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles_categorias_contenido)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rol_categorias_contenido" do
    assert_difference('RolCategoriasContenido.count') do
      post :create, rol_categorias_contenido: { categorias_contenido_id: @rol_categorias_contenido.categorias_contenido_id, rol_id: @rol_categorias_contenido.rol_id }
    end

    assert_redirected_to rol_categorias_contenido_path(assigns(:rol_categorias_contenido))
  end

  test "should show rol_categorias_contenido" do
    get :show, id: @rol_categorias_contenido
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rol_categorias_contenido
    assert_response :success
  end

  test "should update rol_categorias_contenido" do
    patch :update, id: @rol_categorias_contenido, rol_categorias_contenido: { categorias_contenido_id: @rol_categorias_contenido.categorias_contenido_id, rol_id: @rol_categorias_contenido.rol_id }
    assert_redirected_to rol_categorias_contenido_path(assigns(:rol_categorias_contenido))
  end

  test "should destroy rol_categorias_contenido" do
    assert_difference('RolCategoriasContenido.count', -1) do
      delete :destroy, id: @rol_categorias_contenido
    end

    assert_redirected_to roles_categorias_contenido_path
  end
end
