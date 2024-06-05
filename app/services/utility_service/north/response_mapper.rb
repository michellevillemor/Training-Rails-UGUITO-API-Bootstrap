module UtilityService
  module North
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['id'],
            title: book['titulo'],
            author: book['autor'],
            genre: book['genero'],
            image_url: book['imagen_url'],
            publisher: book['editorial'],
            year: book['año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            id: note['id'],
            title: note['titulo'],
            note_type: note['tipo'],
            content: note['contenido'],
            created_at: note['fecha_creacion'],
            author: map_author(note),
            book: map_book(note)
          }
        end
      end

      def map_book(note)
        libro = note['libro']
        {
          id: libro['id'],
          title: libro['titulo'],
          author: libro['autor'],
          genre: libro['genero'],
          image_url: libro['imagen_url'],
          publisher: libro['editorial'],
          year: libro['año']
        }
      end

      def map_author(note)
        {
          contact_info: {
            email: note['email'],
            phone: note['telefono']
          },
          personal_info: {
            document_number: note['nro_documento'],
            name: note['nombre'],
            surname: note['apellido']
          }
        }
      end
    end
  end
end
