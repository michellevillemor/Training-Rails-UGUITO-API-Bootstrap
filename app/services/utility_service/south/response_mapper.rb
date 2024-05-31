module UtilityService
  module South
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['Libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['Notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['Id'],
            title: book['Titulo'],
            author: book['Autor'],
            genre: book['Genero'],
            image_url: book['ImagenUrl'],
            publisher: book['Editorial'],
            year: book['Año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|       
          {
            id: note['Id'],
            title: note['TituloNota'],
            note_review: note['ReseniaNota'],
            created_at: note['FechaCreacionNota'],
            author_email: note['EmailAutor'],
            fullname_author: note['NombreCompletoAutor'],
            book_title: note['TituloLibro'],
            book_author_name: note['NombreAutorLibro'],
            book_genre: note['GeneroLibro'],
            content: note['Contenido'],
          }
        end
      end
    end
  end
end
