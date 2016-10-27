require 'test_helper'

class UsuariosEspecieControllerTest < ActionController::TestCase
  setup do
    @usuario_especie = usuarios_especie(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:usuarios_especie)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create usuario_especie" do
    assert_difference('UsuarioEspecie.count') do
      post :create, usuario_especie: { especie_id: @usuario_especie.especie_id, usuario_id: @usuario_especie.usuario_id }
    end

    assert_redirected_to usuario_especie_path(assigns(:usuario_especie))
  end

  test "should show usuario_especie" do
    get :show, id: @usuario_especie
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @usuario_especie
    assert_response :success
  end

  test "should update usuario_especie" do
    patch :update, id: @usuario_especie, usuario_especie: { especie_id: @usuario_especie.especie_id, usuario_id: @usuario_especie.usuario_id }
    assert_redirected_to usuario_especie_path(assigns(:usuario_especie))
  end

  test "should destroy usuario_especie" do
    assert_difference('UsuarioEspecie.count', -1) do
      delete :destroy, id: @usuario_especie
    end

    assert_redirected_to usuarios_especie_path
  end
end
