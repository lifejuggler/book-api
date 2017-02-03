Rails.application.routes.draw do
  get 'books/index'

  post 'books/request_books'
  post 'books/check_books'

  post 'books/batch_books'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
