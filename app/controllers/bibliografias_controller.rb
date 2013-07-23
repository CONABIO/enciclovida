class BibliografiasController < ApplicationController
  before_action :set_bibliografia, only: [:show, :edit, :update, :destroy]

  # GET /bibliografias
  # GET /bibliografias.json
  def index
    @bibliografias = Bibliografia.all
  end

  # GET /bibliografias/1
  # GET /bibliografias/1.json
  def show
  end

  # GET /bibliografias/new
  def new
    @bibliografia = Bibliografia.new
  end

  # GET /bibliografias/1/edit
  def edit
  end

  # POST /bibliografias
  # POST /bibliografias.json
  def create
    @bibliografia = Bibliografia.new(bibliografia_params)

    respond_to do |format|
      if @bibliografia.save
        format.html { redirect_to @bibliografia, notice: 'Bibliografia was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bibliografia }
      else
        format.html { render action: 'new' }
        format.json { render json: @bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bibliografias/1
  # PATCH/PUT /bibliografias/1.json
  def update
    respond_to do |format|
      if @bibliografia.update(bibliografia_params)
        format.html { redirect_to @bibliografia, notice: 'Bibliografia was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bibliografia.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bibliografias/1
  # DELETE /bibliografias/1.json
  def destroy
    @bibliografia.destroy
    respond_to do |format|
      format.html { redirect_to bibliografias_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bibliografia
      @bibliografia = Bibliografia.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bibliografia_params
      params[:bibliografia]
    end
end
