module UtilityService
  module North
    class ResponseMapper < UtilityService::ResponseMapper
      NOTE_TYPES = {
        'opinion' => 'review',
        'resenia' => 'review',
        'critica' => 'critique'
      }.freeze

      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          map_book(book)
        end
      end

      def map_notes(notes)
        notes.map do |note|
          book = map_book(note['libro'])
          {
            title: note['titulo'],
            note_type: map_note_type(note['tipo']),
            content: note['contenido'],
            created_at: note['fecha_creacion'],
            user: map_author(note['autor']),
            book: {
              title: book[:title],
              author: book[:author],
              genre: book[:genre]
            }
          }
        end
      end

      def map_book(book)
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

      def map_author(author)
        {
          email: author.dig('datos_de_contacto', 'email'),
          first_name: author.dig('datos_personales', 'nombre'),
          last_name: author.dig('datos_personales', 'apellido')
        }
      end

      def map_note_type(note_type)
        NOTE_TYPES[note_type]
      end
    end
  end
end
