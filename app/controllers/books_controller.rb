class BooksController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_book, only: [:edit, :update, :destroy]

  def index
    @books = Book.includes(:user).all.order(created_at: :desc)
  end

  def new
    @book = Book.new
  end

  def search
    query = params[:query].to_s.strip
    @results = query.present? ? OpenLibraryService.search_by_title(query) : []

    respond_to do |format|
      # Renderiza o partial sem o layout global, essencial para o Turbo Frame funcionar
      format.html { render partial: "search_results", locals: { results: @results } }
    end
  end

  def create
    @book = current_user.books.build(book_params)
    
    if @book.save
      redirect_to books_path, notice: "Livro '#{@book.title}' adicionado à sua estante!"
    else
      flash.now[:alert] = "Erro ao efetivar o cadastro."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to books_path, notice: "Status atualizado!"
    else
      render :edit
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "Livro removido.", status: :see_other
  end
  
  private

  def set_book
    @book = current_user.books.find(params[:id])
  end

  def book_params
    # Incluímos :image_url e :isbn para garantir que os dados da API sejam persistidos
    params.require(:book).permit(:title, :author, :isbn, :publish_year, :image_url, :status)
  end
  
  
end