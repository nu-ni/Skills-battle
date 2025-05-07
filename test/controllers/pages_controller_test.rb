require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get welcome" do
    get pages_welcome_url
    assert_response :success
  end

  test "should get menu" do
    get pages_menu_url
    assert_response :success
  end
end
