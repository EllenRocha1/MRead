require 'net/http'
require 'json'

class OpenLibraryService
  BASE_URL = "https://openlibrary.org"
  COVERS_URL = "https://covers.openlibrary.org/b/id/"

  def self.search_by_title(title)
    escaped_title = URI.encode_www_form_component(title)
    
    uri = URI("#{BASE_URL}/search.json?q=#{escaped_title}&limit=5")

    begin
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
    rescue SocketError, Net::OpenTimeout, JSON::ParserError => e
      Rails.logger.error "Erro na API OpenLibrary: #{e.message}"
      return [] 
    end

    return [] if data["docs"].blank?

    data["docs"].map do |book|
      {
        title: book["title"],
        author: book["author_name"]&.first || "Autor desconhecido",
        publish_year: book["first_publish_year"] || book["publish_date"]&.first,
        isbn: book["isbn"]&.first, 
        cover_url: book["cover_i"] ? "#{COVERS_URL}#{book['cover_i']}-M.jpg" : nil
      }
    end
  end

  def self.fetch_by_isbn(isbn)
    uri = URI("#{BASE_URL}/api/books?bibkeys=ISBN:#{isbn}&format=json&jscmd=data")
    
    begin
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
    rescue SocketError, Net::OpenTimeout, JSON::ParserError => e
      Rails.logger.error "Erro na API OpenLibrary (ISBN): #{e.message}"
      return nil
    end
    
    return nil if data.empty?

    book_data = data["ISBN:#{isbn}"]
    {
      title: book_data["title"],
      author: book_data["authors"]&.first&.dig("name") || "Autor desconhecido",
      publish_year: book_data["publish_date"],
      isbn: isbn,
      cover_url: book_data["cover"]&.dig("medium")
    }
  end
end