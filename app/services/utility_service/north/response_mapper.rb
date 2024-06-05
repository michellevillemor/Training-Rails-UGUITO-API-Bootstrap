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
          {
            title: note['titulo'],
            note_type: map_note_type(note['tipo']),
            content: note['contenido'],
            created_at: note['fecha_creacion'],
            user: map_author(note['autor']),
            book: map_book(note['libro'])
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
        author_contact_data = author['datos_de_contacto']
        author_personal_data = author['datos_personales']

        {
          email: author_contact_data['email'],
          name: author_personal_data['nombre'],
          surname: author_personal_data['apellido']
        }
      end

      def map_note_type(note_type)
        NOTE_TYPES[note_type]
      end
    end
  end
end
