require 'test_helper'

class MetadatosControllerTest < ActionController::TestCase
  setup do
    @metadato = metadatos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:metadatos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create metadato" do
    assert_difference('Metadato.count') do
      post :create, metadato: {  }
    end

    assert_redirected_to metadato_path(assigns(:metadato))
  end

  test "should show metadato" do
    get :show, id: @metadato
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @metadato
    assert_response :success
  end

  test "should update metadato" do
    patch :update, id: @metadato, metadato: {  }
    assert_redirected_to metadato_path(assigns(:metadato))
  end

  test "should destroy metadato" do
    assert_difference('Metadato.count', -1) do
      delete :destroy, id: @metadato
    end

    assert_redirected_to metadatos_path
  end
end
