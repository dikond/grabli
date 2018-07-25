require 'spec_helper'

AppPolicy = Struct.new(:current_user, :record)

class User < Struct.new(:admin, :invited_by)
  # simulate ActiveModel
  class Pet
    def model_name
      'Pet'
    end
  end

  class PetPolicy < AppPolicy
    def feed?
      true
    end
  end
end

class UserPolicy < Struct.new(:current_user, :record)
  def create?
    current_user.admin
  end

  def update?
    manage_occupied? || current_user.admin
  end

  def permitted_attributes
    %i[foo]
  end

  def permitted_attributes_for_create
    %i[foo bar]
  end

  private

  def manage_occupied?
    record.invited_by == current_user
  end
end

RSpec.describe Grabli do
  it "has a version number" do
    expect(Grabli::VERSION).not_to be nil
  end

  describe '#collect' do
    subject(:permissions) { described_class.new.collect(current_user, subject) }

    let(:current_user) { admin }
    let(:subject) { user_invited_by_admin }
    let(:admin) { User.new(true, nil) }
    let(:user_invited_by_admin) { User.new(false, admin) }

    it "doesn't include private methods" do
      expect(permissions).not_to include(:manage_occupied?)
    end

    it "doesn't include permitted_attriubutes" do
      expect(permissions).not_to include(:permitted_attriubutes)
      expect(permissions).not_to include(:permitted_attributes_for_create)
    end

    context 'with domain object subject' do
      let(:current_user) { admin }
      let(:subject) { user_invited_by_admin }

      it 'includes allowed permissions which depend on subject' do
        expect(permissions).to match_array %i[create? update?]
      end
    end

    context 'without domain object subject' do
      let(:current_user) { admin }
      let(:subject) { :user }

      it "doesn't include permissions which depend on subject" do
        expect(permissions).to match_array %i[create?]
      end
    end

    context 'with specified namespace' do
      let(:permissions) { described_class.new(namespace: User).collect(current_user, subject) }
      let(:current_user) { User.new(true, nil) }
      let(:subject) { User::Pet.new }

      it 'searches under given namespace for policy class' do
        expect(permissions).to eq [:feed?]
      end
    end

    context 'when unable to find policy' do
      let(:permissions) { described_class.new(namespace: User::Pet).collect(current_user, subject) }
      let(:current_user) { User.new(true, nil) }
      let(:subject) { User::Pet.new }

      it { expect { permissions }.to raise_error(Grabli::PolicyNotFound) }
    end
  end
end
