# frozen_string_literal: true

require 'spec_helper'

# A CEP in; the street, the neighbourhood and the City out (BrasilAPI). Every
# provider sits behind one seam, `Postal.http`, so nothing here reaches the
# network. The typing search (suggest · pick) has its own files per provider.
describe Geopolitical::Postal do
  let!(:brazil) { Fabricate(:nation, name: 'Brazil', abbr: 'BR') }
  let!(:sp) { Fabricate(:region, name: 'São Paulo', abbr: 'SP', nation: brazil) }

  # BrasilAPI v2's own answer for this CEP, trimmed to what is read.
  let(:paulista) do
    { 'cep' => '01311925', 'state' => 'SP', 'city' => 'São Paulo', 'neighborhood' => 'Bela Vista',
      'street' => 'Avenida Paulista', 'ibge' => { 'city' => '3550308', 'state' => '35' } }
  end

  it 'fills the street, the neighbourhood and the City it finds by IBGE code' do
    city = Fabricate(:city, name: 'São Paulo', region: sp, nation: brazil, code: '3550308')
    allow(described_class).to receive(:http).with('https://brasilapi.com.br/api/cep/v2/01311925').and_return(paulista)

    found = described_class.find('01311-925')

    expect(found).to have_attributes(postal: '01311-925', street: 'Avenida Paulista',
                                     hood: 'Bela Vista', city: city)
  end

  # The one-CEP towns are the ones a city table is most likely to lack.
  it 'makes the City it does not have, under the state it names' do
    allow(described_class).to receive(:http).and_return(paulista)

    city = described_class.find('01311925').city

    expect(city).to be_persisted
    expect(city).to have_attributes(name: 'São Paulo', code: '3550308', region: sp, nation: brazil)
  end

  it 'takes the City another request just made, when its own insert loses the race' do
    winner = Fabricate(:city, name: 'São Paulo', region: sp, nation: brazil)
    allow(City).to receive(:where).and_call_original
    allow(City).to receive(:where).with(slug: 'sao-paulo-sp').and_return(City.none, City.where(id: winner.id))
    allow(City).to receive(:create).and_raise(Mongo::Error::OperationFailure, 'E11000 duplicate key')
    allow(described_class).to receive(:http).and_return(paulista.merge('ibge' => nil))

    expect(described_class.find('01311925').city).to eq(winner)
  end

  it 'fills what it can and leaves the City blank when it cannot place the state' do
    allow(described_class).to receive(:http).and_return(paulista.merge('state' => 'ZZ'))

    expect(described_class.find('01311925')).to have_attributes(street: 'Avenida Paulista', city: nil)
  end

  it 'takes a town-wide CEP with no street as a city and nothing else' do
    Fabricate(:city, name: 'Monte Santo de Minas', region: sp, nation: brazil, code: '3143203')
    allow(described_class).to receive(:http)
      .and_return(paulista.merge('street' => nil, 'neighborhood' => '', 'city' => 'Monte Santo de Minas',
                                 'ibge' => { 'city' => '3143203' }))

    expect(described_class.find('37958000')).to have_attributes(street: nil, hood: nil,
                                                                city: have_attributes(code: '3143203'))
  end

  it 'answers nothing for a code nobody has, and never asks for one that is not eight digits' do
    allow(described_class).to receive(:http).and_return(nil)

    expect(described_class.find('99999-999')).to be_nil
    expect(described_class.find('1234')).to be_nil
    expect(described_class).to have_received(:http).once
  end

  it 'knows only Brazil, and says nothing for anywhere else' do
    allow(described_class).to receive(:http)

    expect(described_class.find('10001', nation: 'US')).to be_nil
    expect(described_class).not_to have_received(:http)
  end

  # No provider, or a provider with no key: the typing search is off, and says
  # so with an empty list rather than a call that can only fail.
  it 'searches nothing while no provider is configured' do
    allow(described_class).to receive(:http)
    Geopolitical.postal_provider = :google
    Geopolitical.postal_key = nil

    expect(described_class.suggest('avenida paulista', session: 't')).to eq([])
    expect(described_class.pick('ChIJ', session: 't')).to be_nil
    expect(described_class).not_to have_received(:http)
  ensure
    Geopolitical.postal_provider = nil
  end

  it 'refuses a provider it does not know, loudly' do
    Geopolitical.postal_provider = :bing
    Geopolitical.postal_key = 'k'

    expect { described_class.suggest('avenida paulista') }.to raise_error(KeyError)
  ensure
    Geopolitical.postal_provider = Geopolitical.postal_key = nil
  end

  # Offline, a 400, a timeout: the person at the form types it by hand.
  it 'treats a provider that fails as a code it does not know' do
    allow(Net::HTTP).to receive(:start).and_raise(Net::OpenTimeout)

    expect(described_class.http('https://brasilapi.com.br/api/cep/v2/01311925')).to be_nil
  end
end
