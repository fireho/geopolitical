# frozen_string_literal: true

module Geopolitical
  class CitiesController < ApplicationController
    before_action :set_city, only: %i[show edit update destroy]
    before_action :set_form_options, only: %i[new edit create update]

    def index
      @cities = City.ordered
    end

    def show; end

    def new
      @city = City.new
    end

    def edit; end

    def create
      @city = City.new(city_params)
      if @city.save
        redirect_to city_path(@city), notice: t('geopolitical.flash.created', model: City.model_name.human)
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @city.update(city_params)
        redirect_to city_path(@city), notice: t('geopolitical.flash.updated', model: City.model_name.human)
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @city.destroy
      redirect_to cities_path, notice: t('geopolitical.flash.destroyed', model: City.model_name.human)
    end

    private

    def set_city
      @city = City.find(params[:id])
    end

    def set_form_options
      @nations = Nation.ordered.map { |nation| [nation.to_s, nation.id] }
      @regions = Region.ordered.map { |region| [region.to_s, region.id] }
    end

    def city_params
      params.require(:city).permit(:name, :slug, :nation_id, :region_id, :souls, :postal, :phone)
    end
  end
end
