# frozen_string_literal: true

module Geopolitical
  class NationsController < ApplicationController
    before_action :set_nation, only: %i[show edit update destroy]

    def index
      @nations = Nation.ordered
    end

    def show; end

    def new
      @nation = Nation.new
    end

    def edit; end

    def create
      @nation = Nation.new(nation_params)
      if @nation.save
        redirect_to nation_path(@nation), notice: t('geopolitical.flash.created', model: Nation.model_name.human)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @nation.update(nation_params)
        redirect_to nation_path(@nation), notice: t('geopolitical.flash.updated', model: Nation.model_name.human)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @nation.destroy
      redirect_to nations_path, notice: t('geopolitical.flash.destroyed', model: Nation.model_name.human)
    end

    private

    def set_nation
      @nation = Nation.find(params[:id])
    end

    def nation_params
      params.require(:nation).permit(:name, :abbr, :slug, :lang, :cash, :code, :code3, :tld, :postal, :phone)
    end
  end
end
