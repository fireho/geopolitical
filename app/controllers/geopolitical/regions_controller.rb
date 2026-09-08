# frozen_string_literal: true

module Geopolitical
  class RegionsController < ApplicationController
    before_action :set_region, only: %i[show edit update destroy]
    before_action :set_nation_options, only: %i[new edit create update]

    def index
      @regions = Region.ordered
    end

    def show; end

    def new
      @region = Region.new
    end

    def edit; end

    def create
      @region = Region.new(region_params)
      if @region.save
        redirect_to region_path(@region), notice: t('geopolitical.flash.created', model: Region.model_name.human)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @region.update(region_params)
        redirect_to region_path(@region), notice: t('geopolitical.flash.updated', model: Region.model_name.human)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @region.destroy
      redirect_to regions_path, notice: t('geopolitical.flash.destroyed', model: Region.model_name.human)
    end

    private

    def set_region
      @region = Region.find(params[:id])
    end

    def set_nation_options
      @nations = Nation.ordered.map { |nation| [nation.to_s, nation.id] }
    end

    def region_params
      params.require(:region).permit(:name, :abbr, :slug, :nation_id, :timezone, :postal, :phone)
    end
  end
end
