# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:email).is_at_most(255) }

    it { should validate_presence_of(:nickname) }
    it { should validate_uniqueness_of(:nickname) }
    it { should validate_length_of(:nickname).is_at_most(20) }

    it { should have_secure_password }
    it { should validate_length_of(:password).is_at_least(8) }
  end

  describe 'normalize' do
    it 'downcase for email' do
      user = create(:user, email: 'RAPHAEL@EXEMPLO.COM')
      expect(user.email).to eq('raphael@exemplo.com')
    end

    it 'delete spaces for email' do
      user = create(:user, email: '  raphael@exemplo.com  ')
      expect(user.email).to eq('raphael@exemplo.com')
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, password: 'senha1234', password_confirmation: 'senha1234') }

    it 'when password is correct' do
      expect(user.authenticate('senha1234')).to be_truthy
    end

    it 'when password is incorrect' do
      expect(user.authenticate('senha_incorreta')).to be_falsey
    end

    it 'when password_confirmation does not match' do
      user = build(:user, password: 'senha1234', password_confirmation: 'senha_diferente')
      user.valid?
      expect(user.errors[:password_confirmation]).to include('não é igual a Senha')
    end
  end

  describe 'when user already exists' do
    it 'when email already exists' do
      create(:user, email: 'existente@exemplo.com')
      user = build(:user, email: 'existente@exemplo.com')
      user.valid?
      expect(user.errors[:email]).to include('já está em uso')
    end

    it 'when password is too short' do
      user = build(:user, password: '123')
      user.valid?
      expect(user.errors[:password]).to include('é muito curta (mínimo 8 caracteres)')
    end
  end
end