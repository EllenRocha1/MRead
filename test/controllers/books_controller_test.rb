require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get books_url
    assert_response :success
  end

  test "unauthenticated users should be redirected from new" do
    get new_book_url
    assert_redirected_to new_user_session_path
  end
end
