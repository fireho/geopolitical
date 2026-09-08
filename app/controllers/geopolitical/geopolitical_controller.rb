# frozen_string_literal: true

module Geopolitical
  class GeopoliticalController < ApplicationController
    def index; end

    def show
      render :index
    end

    def new
      redirect_to root_path
    end

    def edit
      redirect_to root_path
    end
  end
end
