# frozen_string_literal: true

require 'spec_helper'

describe 'Geopolitical engine', type: :request do
  let!(:nation) { Fabricate(:nation, name: 'Brasil', abbr: 'BR') }
  let!(:region) { Fabricate(:region, name: 'São Paulo', abbr: 'SP', nation: nation) }
  let!(:city)   { Fabricate(:city, name: 'Santos', region: region, nation: nation) }
  let!(:hood)   { Fabricate(:hood, name: 'Gonzaga', city: city) }

  it 'renders the dashboard' do
    get '/'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Geopolitical')
  end

  # [model, existing record, valid attrs, updated name]
  {
    'nations' => [Nation, -> { nation }, -> { { name: 'Testland', abbr: 'TL' } }],
    'regions' => [Region, -> { region }, -> { { name: 'Bahia', abbr: 'BA', nation_id: Nation.first.id } }],
    'cities' => [City, -> { city }, -> { { name: 'Recife', nation_id: Nation.first.id } }],
    'hoods' => [Hood, -> { hood }, -> { { name: 'Boa Viagem', city_id: City.first.id } }]
  }.each do |path, (model, existing, attrs)|
    describe "/#{path}" do
      let(:record) { instance_exec(&existing) }
      let(:param)  { model.name.downcase }

      it 'lists' do
        get "/#{path}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(record.name)
      end

      it 'shows the form pages' do
        get "/#{path}/new"
        expect(response).to have_http_status(:ok)
        get "/#{path}/#{record.to_param}/edit"
        expect(response).to have_http_status(:ok)
      end

      it 'creates' do
        expect { post "/#{path}", params: { param => instance_exec(&attrs) } }.to change(model, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end

      it 'rejects an invalid create' do
        expect { post "/#{path}", params: { param => { name: '' } } }.not_to change(model, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'updates' do
        patch "/#{path}/#{record.to_param}", params: { param => { name: 'Renamed' } }
        expect(response).to have_http_status(:redirect)
        expect(record.reload.name).to eq('Renamed')
      end

      it 'destroys' do
        expect { delete "/#{path}/#{record.to_param}" }.to change(model, :count).by(-1)
        expect(response).to redirect_to("/#{path}")
      end
    end
  end

  describe '/nations' do
    it 'shows a nation by its abbr' do
      get '/nations/BR'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Brasil')
    end
  end

  describe '/cities' do
    it 'shows a city with its region and hoods' do
      get "/cities/#{city.to_param}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Santos')
    end
  end

  describe 'parent_controller' do
    it 'defaults to ActionController::Base and is what the engine inherits' do
      expect(Geopolitical.parent_controller).to eq('ActionController::Base')
      expect(Geopolitical::ApplicationController.superclass.name).to eq(Geopolitical.parent_controller)
    end

    it 'is settable, so a host can inject its own authentication' do
      Geopolitical.parent_controller = 'ApplicationController'
      expect(Geopolitical.parent_controller).to eq('ApplicationController')
    ensure
      Geopolitical.parent_controller = 'ActionController::Base'
    end
  end
  describe 'i18n' do
    around { |example| I18n.with_locale(:pt) { example.run } }

    it 'translates model and attribute names' do
      expect(City.model_name.human(count: 2)).to eq('Cidades')
      expect(Region.model_name.human).to eq('Região')
      expect(Hood.human_attribute_name(:souls)).to eq('População')
    end

    it 'renders the UI in Portuguese' do
      get '/cities'
      expect(response.body).to include('Cidades', 'Adicionar Cidade', 'População', 'Remover')
    end

    it 'flashes in Portuguese' do
      post '/nations', params: { nation: { name: 'Testelandia', abbr: 'TX' } }
      follow_redirect!
      expect(response.body).to include('Registro criado com sucesso.')
    end
  end
end
