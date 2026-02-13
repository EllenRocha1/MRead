require 'net/http'
require 'json'

class OpenLibraryService
  BASE_URL = "https://openlibrary.org"
  COVERS_URL = "https://covers.openlibrary.org/b/id/"
  REQUEST_TIMEOUT = 5

  # Escopo de classe: Todos os métodos aqui dentro são 'self.' automaticamente
  class << self
    
    def search_by_title(title)
      escaped_title = URI.encode_www_form_component(title)
      uri = URI("#{BASE_URL}/search.json?q=#{escaped_title}&limit=5")

      data = fetch_json(uri)
      return [] if data.blank? || data["docs"].blank?

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

    def fetch_by_isbn(isbn)
      uri = URI("#{BASE_URL}/api/books?bibkeys=ISBN:#{isbn}&format=json&jscmd=data")
      
      data = fetch_json(uri)
      return nil if data.blank? || data.empty?

      book_data = data["ISBN:#{isbn}"]
      {
        title: book_data["title"],
        author: book_data["authors"]&.first&.dig("name") || "Autor desconhecido",
        publish_year: book_data["publish_date"],
        isbn: isbn,
        cover_url: book_data["cover"]&.dig("medium")
      }
    end

    private # Daqui para baixo, apenas a própria classe enxerga os métodos

    def fetch_json(uri)
      request = Net::HTTP::Get.new(uri)
      
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: REQUEST_TIMEOUT, read_timeout: REQUEST_TIMEOUT) do |http|
        http.request(request)
      end

      return nil unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue SocketError, Net::OpenTimeout, Net::ReadTimeout, JSON::ParserError => e
      Rails.logger.error "🚨 Erro na API OpenLibrary: #{e.message}"
      nil
    end
  end 
end