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
            title: note['TituloNota'],
            note_type: map_note_type(note),
            created_at: note['FechaCreacionNota'],
            content: note['Contenido'],
            user: {
              email: note['EmailAutor'],
              first_name: map_name(note)[:first_name],
              last_name: map_name(note)[:last_name]
            },
            book: {
              title: note['TituloLibro'],
              author: note['NombreAutorLibro'],
              genre: note['GeneroLibro']
            }
          }
        end
      end

      def map_note_type(note)
        note['ReseniaNota'] ? 'review' : 'critique'
      end

      def map_name(note)
        full_name = note['NombreCompletoAutor']
        splitted_full_name = full_name.split
        {
          first_name: splitted_full_name[0],
          last_name: splitted_full_name[1..].join(' ')
        }
      end
    end
  end
end
