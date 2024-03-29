# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session #:exception
  before_action :set_locale#, :authenticate  ##Autentica por credenciales generales
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_header_background

  def to_boolean(str)
    str.downcase == 'true' ? true : false
  end

  def set_locale
    I18n.locale = cookies[:vista].present? ? cookies[:vista] : I18n.default_locale
  end

  def set_header_background
    @bgImg = "/fondos/#{rand(1..16)}.jpg"
  end


  protected

  # Limita la aplicacion a un usuario y contrasenia general
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == CONFIG.username.to_s && password == CONFIG.password.to_s
    end
  end

  # Atributos adicionales para el registro y autenticacion
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :nombre, :apellido, :institucion])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :email, :password, :remember_me])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :nombre, :apellido, :institucion])
  end

  def tiene_permiso?(nombre_rol, con_hijos=false)
    render 'shared/sin_permiso' and return unless usuario_signed_in? #con esto aseguramos que el usuario ya inicio sesión
    roles_usuario = current_usuario.usuario_roles.map(&:rol)
    #Si se es superusuario o algun otro tipo de root, entra a ALL
    return if roles_usuario.map(&:depth).any?{|d| d < 1}
    rol = Rol.find_by_nombre_rol(nombre_rol)
    #Si solicito vástagos, entonces basta con ser hijo del mínimo requerido:
    return if con_hijos && roles_usuario.map(&:path_ids).flatten.include?(rol.id)
    #Si no requiero vastagos revisa si el nombre_rol pertenece al linaje (intersección del subtree_ids del usuario y del rol)
    render 'shared/sin_permiso' unless rol.present? && (roles_usuario.map(&:subtree_ids).flatten & rol.path_ids).any?
  end

  def es_propietario?(obj)
    return false unless usuario_signed_in?
    usuario_id = obj.usuario_id
    current_usuario.id == usuario_id
  end

  # TODO: las consultas pasarlas a json para que con el cache no vuelva a ocupar la base
  def cache_filtros_ev
    @filtros = Rails.cache.fetch("filtros_ev", expires_in: eval(CONFIG.cache.filtros_ev)) do
      
      anim = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_ANIMALES)
      animales = []
      anim.each do |animal|
        if index = Busqueda::GRUPOS_ANIMALES.index(animal.nombre_cientifico)
          animales[index] = animal
        end
      end
  
      plant = Especie.select_grupos_iconicos.where(nombre_cientifico: Busqueda::GRUPOS_PLANTAS_Y_HONGOS)
      plantas = []
      plant.each do |planta|
        if index = Busqueda::GRUPOS_PLANTAS_Y_HONGOS.index(planta.nombre_cientifico)
          plantas[index] = planta
        end
      end
      
      nom_cites_iucn_todos = Catalogo.nom_cites_iucn_todos
      tipos_distribuciones = TipoDistribucion.distribuciones(I18n.locale.to_s == 'es-cientifico')
      prioritarias = Catalogo.prioritarias
      usos = Catalogo.usos
      ambientes = Catalogo.ambientes
      distribuciones = Region.dame_regiones_filtro
      formas_crecimiento = Catalogo.formas_crecimiento

      { animales: animales, plantas: plantas, nom_cites_iucn_todos: nom_cites_iucn_todos, tipos_distribuciones: tipos_distribuciones, prioritarias: prioritarias, usos: usos, ambientes: ambientes, distribuciones: distribuciones, formas_crecimiento: formas_crecimiento }
    end
  end

end
