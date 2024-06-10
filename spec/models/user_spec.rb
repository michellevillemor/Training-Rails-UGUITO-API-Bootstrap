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
    let(:user) { create(:user, first_name: first_name, last_name: last_name) }

    context 'when both first name and last name are present' do
      it 'returns the full name of the user' do
        expect(user.full_name).to eq("#{first_name} #{last_name}")
      end
    end

    context 'when the first name is missing' do
      let(:first_name) { '' }
  
      it 'returns the last name only' do
        expect(user.full_name).to eq(last_name)
      end
    end

    context 'when the last name is missing' do
      let(:last_name) { '' }
  
      it 'returns the first name only' do
        expect(user.full_name).to eq(first_name)
      end
    end

    context 'when both first name and last name are missing' do
      let(:first_name) { '' }
      let(:last_name) { '' }
  
      it 'returns an empty string' do
        expect(user.full_name).to eq('')
      end
    end
  end
end
