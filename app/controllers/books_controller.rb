class BooksController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_book, only: [:edit, :update, :destroy]

  # 1. LISTAGEM COM ESCOPO (Global vs Pessoal)
  def index
    if user_signed_in? && params[:view] == "mine"
      @books = current_user.books.order(created_at: :desc)
      @title = "Minha Estante"
    else
      @books = Book.includes(:user).all.order(created_at: :desc)
      @title = "Acervo Comunitário"
    end
  end

  def new
    @book = Book.new
  end

  # 2. BUSCA DINÂMICA (Requisito JS)
  def search
    query = params[:query].to_s.strip
    @results = query.present? ? OpenLibraryService.search_by_title(query) : []

    respond_to do |format|
      format.html { render partial: "search_results", locals: { results: @results } }
    end
  end

  # 3. CRIAÇÃO (Persistência no SQLite)
  def create
    @book = current_user.books.build(book_params)
    
    if @book.save
      redirect_to books_path, notice: "Livro '#{@book.title}' adicionado com sucesso!"
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
      render :edit, status: :unprocessable_entity
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
    params.require(:book).permit(:title, :author, :isbn, :publish_year, :image_url, :status)
  end
end