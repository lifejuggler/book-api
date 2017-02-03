require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get request" do
    get books_request_url
    assert_response :success
  end

  test "should get check" do
    get books_check_url
    assert_response :success
  end

  test "should get batch" do
    get books_batch_url
    assert_response :success
  end

end
