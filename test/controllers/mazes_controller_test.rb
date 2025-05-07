require "test_helper"

class MazesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mazes_index_url
    assert_response :success
  end

  test "should get new" do
    get mazes_new_url
    assert_response :success
  end

  test "should get play" do
    get mazes_play_url
    assert_response :success
  end
end
