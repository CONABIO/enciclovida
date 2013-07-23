class EstatusesController < ApplicationController
  before_action :set_estatuse, only: [:show, :edit, :update, :destroy]

  # GET /estatuses
  # GET /estatuses.json
  def index
    @estatuses = Estatus.all
  end

  # GET /estatuses/1
  # GET /estatuses/1.json
  def show
  end

  # GET /estatuses/new
  def new
    @estatuse = Estatus.new
  end

  # GET /estatuses/1/edit
  def edit
  end

  # POST /estatuses
  # POST /estatuses.json
  def create
    @estatuse = Estatus.new(estatuse_params)

    respond_to do |format|
      if @estatuse.save
        format.html { redirect_to @estatuse, notice: 'Estatus was successfully created.' }
        format.json { render action: 'show', status: :created, location: @estatuse }
      else
        format.html { render action: 'new' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /estatuses/1
  # PATCH/PUT /estatuses/1.json
  def update
    respond_to do |format|
      if @estatuse.update(estatuse_params)
        format.html { redirect_to @estatuse, notice: 'Estatus was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @estatuse.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /estatuses/1
  # DELETE /estatuses/1.json
  def destroy
    @estatuse.destroy
    respond_to do |format|
      format.html { redirect_to estatuses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_estatuse
      @estatuse = Estatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def estatuse_params
      params[:estatuse]
    end
end
