require 'test_helper'

class CategoriaContenidosRolesControllerTest < ActionController::TestCase
  setup do
    @categoria_contenido_rol = categoria_contenidos_roles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categoria_contenidos_roles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create categoria_contenido_rol" do
    assert_difference('CategoriaContenidoRol.count') do
      post :create, categoria_contenido_rol: { categoria_contenido_id: @categoria_contenido_rol.categoria_contenido_id, rol_id: @categoria_contenido_rol.rol_id }
    end

    assert_redirected_to categoria_contenido_rol_path(assigns(:categoria_contenido_rol))
  end

  test "should show categoria_contenido_rol" do
    get :show, id: @categoria_contenido_rol
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @categoria_contenido_rol
    assert_response :success
  end

  test "should update categoria_contenido_rol" do
    patch :update, id: @categoria_contenido_rol, categoria_contenido_rol: { categoria_contenido_id: @categoria_contenido_rol.categoria_contenido_id, rol_id: @categoria_contenido_rol.rol_id }
    assert_redirected_to categoria_contenido_rol_path(assigns(:categoria_contenido_rol))
  end

  test "should destroy categoria_contenido_rol" do
    assert_difference('CategoriaContenidoRol.count', -1) do
      delete :destroy, id: @categoria_contenido_rol
    end

    assert_redirected_to categoria_contenidos_roles_path
  end
end
