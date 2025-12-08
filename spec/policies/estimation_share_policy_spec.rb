require 'rails_helper'

RSpec.describe EstimationSharePolicy, type: :policy do
  let(:owner) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:estimation) { FactoryBot.create(:estimation, user: owner) }
  let(:estimation_share) { FactoryBot.create(:estimation_share, estimation: estimation) }

  describe '#index?' do
    context 'when user is the estimation owner' do
      subject { described_class.new(owner, estimation_share) }

      it 'permits access' do
        expect(subject.index?).to be true
      end
    end

    context 'when user is not the estimation owner' do
      subject { described_class.new(other_user, estimation_share) }

      it 'denies access' do
        expect(subject.index?).to be false
      end
    end
  end

  describe '#create?' do
    context 'when user is the estimation owner' do
      subject { described_class.new(owner, estimation_share) }

      it 'permits access' do
        expect(subject.create?).to be true
      end
    end

    context 'when user is not the estimation owner' do
      subject { described_class.new(other_user, estimation_share) }

      it 'denies access' do
        expect(subject.create?).to be false
      end
    end
  end

  describe '#destroy?' do
    context 'when user is the estimation owner' do
      subject { described_class.new(owner, estimation_share) }

      it 'permits access' do
        expect(subject.destroy?).to be true
      end
    end

    context 'when user is not the estimation owner' do
      subject { described_class.new(other_user, estimation_share) }

      it 'denies access' do
        expect(subject.destroy?).to be false
      end
    end
  end

  describe '#transfer_ownership?' do
    context 'when user is the estimation owner' do
      subject { described_class.new(owner, estimation_share) }

      it 'permits access' do
        expect(subject.transfer_ownership?).to be true
      end
    end

    context 'when user is not the estimation owner' do
      subject { described_class.new(other_user, estimation_share) }

      it 'denies access' do
        expect(subject.transfer_ownership?).to be false
      end
    end

    context 'when user has owner role share but is not the estimation owner' do
      let(:shared_owner) { FactoryBot.create(:user) }
      let!(:owner_share) { FactoryBot.create(:estimation_share, :active, :owner, estimation: estimation, shared_with_user: shared_owner) }
      subject { described_class.new(shared_owner, estimation_share) }

      it 'denies access (only actual owner can transfer)' do
        expect(subject.transfer_ownership?).to be false
      end
    end
  end
end
