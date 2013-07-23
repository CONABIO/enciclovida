require 'test_helper'

class BibliografiasControllerTest < ActionController::TestCase
  setup do
    @bibliografia = bibliografias(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bibliografias)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bibliografia" do
    assert_difference('Bibliografia.count') do
      post :create, bibliografia: {  }
    end

    assert_redirected_to bibliografia_path(assigns(:bibliografia))
  end

  test "should show bibliografia" do
    get :show, id: @bibliografia
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bibliografia
    assert_response :success
  end

  test "should update bibliografia" do
    patch :update, id: @bibliografia, bibliografia: {  }
    assert_redirected_to bibliografia_path(assigns(:bibliografia))
  end

  test "should destroy bibliografia" do
    assert_difference('Bibliografia.count', -1) do
      delete :destroy, id: @bibliografia
    end

    assert_redirected_to bibliografias_path
  end
end
