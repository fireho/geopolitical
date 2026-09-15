# frozen_string_literal: true

module Geopolitical
  class HoodsController < ApplicationController
    before_action :set_hood, only: %i[show edit update destroy]
    before_action :set_city_options, only: %i[new edit create update]

    def index
      @hoods = Hood.ordered
    end

    def show; end

    def new
      @hood = Hood.new
    end

    def edit; end

    def create
      @hood = Hood.new(hood_params)
      if @hood.save
        redirect_to hood_path(@hood), notice: t('geopolitical.flash.created', model: Hood.model_name.human)
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @hood.update(hood_params)
        redirect_to hood_path(@hood), notice: t('geopolitical.flash.updated', model: Hood.model_name.human)
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @hood.destroy
      redirect_to hoods_path, notice: t('geopolitical.flash.destroyed', model: Hood.model_name.human)
    end

    private

    def set_hood
      @hood = Hood.find(params[:id])
    end

    def set_city_options
      @cities = City.ordered.map { |city| [city.to_s, city.id] }
    end

    def hood_params
      params.require(:hood).permit(:name, :slug, :city_id, :souls, :rank, :postal, :phone)
    end
  end
end
