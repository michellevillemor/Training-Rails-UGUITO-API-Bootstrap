require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  %i[email password].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it { is_expected.to validate_confirmation_of(:password) }

  it { is_expected.to belong_to(:utility) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe '#full_name' do
      let(:first_name) { Faker::Name.neutral_first_name }
      let(:last_name) { Faker::Name.last_name }

    it 'returns the full name of the user' do
      user = User.new(first_name: first_name, last_name: last_name)
      expect(user.full_name).to eq("#{first_name} #{last_name}")
    end

    it 'handles missing first name' do
      user = User.new(first_name: '', last_name: last_name)
      expect(user.full_name).to eq("#{last_name}")
    end

    it 'handles missing last name' do
      user = User.new(first_name: first_name, last_name: '')
      expect(user.full_name).to eq("#{first_name}")
    end

    it 'handles missing first and last name' do
      user = User.new(first_name: '', last_name: '')
      expect(user.full_name).to eq('')
    end
  end
end
