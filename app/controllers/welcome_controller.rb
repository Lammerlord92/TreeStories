class WelcomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @categories = Category.all

    # Done. 5 historias más adquiridas en los últimos 7 días.
    @slice_stories = Addition.where('created_at > ?', Date.today - 7.days).group(:story).order('count_id desc').count('id').keys[0..4]
    # Solución provisional
    @slice_stories.each do |slice_story|
      if slice_story.cover == nil
        cat = I18n.transliterate(slice_story.categories.first.name).downcase
        slice_story.cover = "/assets/categories_covers/" + cat + ".jpg"
      end
    end

    # Done
    @newest_stories_by_category = Hash.new
    @categories.each do |category|

      # Categories without stories aren't showed at index
      if not category.stories.empty?
        stories = category.stories.order(release_date: :desc).limit(3)
        @newest_stories_by_category[category] = stories
      end

    end

    # Done. Se muestran los perfiles de los usuarios cuyos libros tienen más adquisiciones.
    #@writers = Profile.where(id: Addition.group(:story).order('count_id desc').count('id').keys[0..25].map(&:profile_id)).limit(6)

    # Done. Devolvemos los autores que han publicado las últimas historias
    # 1. Creamos dos arrays vacíos para guardar los escritores que recorramos y que devolvamos
    # 2. Ordenamos las historias por fecha de salida
    # 3. Recorremos el array de historias (De 0-10, lo suyo es de 0-longitud)
    # 4. Suponemos que el autor de la historia seleccionada no ha sido añadido aún
    # 5. Recorremos el listado de autores añadidos y comprobamos si está apuntado
    # 6. Si no estaba apuntado, y mientras no hayan 6 autores, lo apuntamos y lo devolvemos
    #TODO Es necesario recorrer desde 0 hasta el tamaño de la lista de historias ordenadas
    @writers = Array.new()
    @addedWriters = Array.new()
    @newest_stories=Story.order(release_date: :desc)

    @newest_stories.each do |story|
      isAdded = false
      author = story.creatorProfile

      @addedWriters.each do |authorID|
        if authorID == author.id
          isAdded = true
        end
      end

      if(isAdded==false)
        if(@addedWriters.size<6)
          @writers.push(author)
          @addedWriters.push(author.id)
        end
      end

    end

    render 'index'
  end
end
