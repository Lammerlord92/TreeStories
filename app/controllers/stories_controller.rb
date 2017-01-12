class StoriesController < ApplicationController
before_action :authenticate_user!, except: [:example ]
  #GET /stories
  def index
    @stories = Story.all
  end

  # Devuelve una lista con las historias adquiridas por
  # el usuario logueado o un aviso si no tiene
  def acquired
    profile  = Profile.find_by(user: current_user)
    additions = Addition.where(profile_id: profile)
    @stories = []
    additions.each do |addition|
      @stories << addition.story
    end
    if @stories.blank?
      flash.now.alert = 'No se han encontrado resultados'
    end
  end

  # Devuelve una lista con las historias creadas por
  # el usuario logueado o un aviso si no tiene
  def created
    #profile  = Profile.find_by(user: current_user)
    @stories = current_user.profile.stories
    if @stories.blank?
      flash.now.alert = 'No se han encontrado resultados'
    end
  end

  #GET /stories/read/:id
  def read
    # @story = Story.find(params[:id])
  end

  def example
    @story = Story.find_by_title('Caperucita Roja')
    render 'stories/dbread'
  end

  def dbread
    @story = Story.find(params[:id]);
  end

  #GET /stories/:id
  def show
    begin
    @story = Story.find(params[:id])
    @comments = @story.comments
    rescue ActiveRecord::RecordNotFound => e
      render 'errors/not_found'
    end
  end

  #GET /stories/new
  def new
    @story = Story.new
    @categories = Category.all
  end

  def edit
    begin
      @story = set_story
    end
  end

  #POST /stories
  def create
    @story = Story.new(story_params)
    @story.num_purchased = 0
    @story.published = false
    @story.creatorProfile = current_user.profile
    @story.categories = params[:categories]
    @categories = Category.all

    # No se muestra en esta versión
    @story.language = "SPANISH"
    @story.price = 0.0

    if @story.save
      redirect_to @story
    else
      @categories = Category.all
      flash[:alert] = 'Error almacenando historia'
      render :new
    end
  end

  def update
    @story = set_story
    @story.categories = params[:categories]
    @categories = Category.all
    #if is_current_profile? @profile # No permitas que un usuario edite un perfil que no es suyo

    #puts(story_params)
    @newCategories = params[:categories]
    logger.debug "--------------- new categories #{@newCategories}"

    if (!@newCategories.nil?)
      @localCategories = Category.find(@newCategories)
      logger.debug "---------------- localCategories #{@localCategories.to_ary}"
    end

    if @localCategories == nil
      flash.now.alert = 'Es obligatorio añadir una categoría al menos'
      render :edit
      logger.debug "------------- ENTRA!!!"

    else
      @other = @story.categories.to_ary
      logger.debug "------------- my categories #{@other}"
      @story.categories.delete_all
      logger.debug "------------- my categoriesVacía #{@other}"
      @story.categories.push(@localCategories.to_ary)
      logger.debug "------------- my categories #{@story.categories.to_ary}"
      #@story.assign_attributes(:categories => @newCategories)
      #@originalCaterogiesStory = @story.categories
      #logger.debug "----------- my categories #{@originalCaterogiesStory}"

      if @story.update(story_params_update)

        #if @story.update_attributes(params[:category])
        redirect_to @story
      else
        render :edit
      end

    end


    #else
     # render 'errors/permission_denied'
    #end
  end

  def story_params


    # Con frontpage -> params.require(:story).permit(:title,:description,:cover,:frontpage,:language,:price,:release_date,:published,:num_purchased)
    params.require(:story).permit(:title,:description,:cover,:frontpage,:language,:price,:release_date,:published,:num_purchased,:category_id)
  end

  def story_params_update
    params.require(:story).permit(:title,:description,:cover,:frontpage,:language,:price,:release_date,:published,:num_purchased,:category_id)
  end


  def search
    @categories = Category.all

    if params[:q]
      @q = params[:q].downcase
      query = 'lower(title) like :q OR lower(description) like :q OR lower(language) like :q and published = true'
      if @q
        @stories = Story.where(query, {q: "%#{@q}%"})
        if @stories.blank?
          flash.now.alert = 'No se han encontrado resultados'
        end
      else
        @stories = Story.where(published: true)
      end
    end

    if params[:category_id]
      category_id = params[:category_id].to_i
      if category_id > 0
        @category = Category.find(category_id)
        stories_by_category = @category.stories
      end
      if @stories and category_id > 0
        @stories = @stories & stories_by_category # Intersección de conjunto en Ruby2
      else
        @stories = stories_by_category
      end
    end

    if params[:q] == nil and params[:category_id] == nil
      @stories = Story.all
    end
  end

  def set_story
    @story=Story.find(params[:id])
  end

end