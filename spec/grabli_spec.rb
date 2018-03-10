require 'spec_helper'

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
  end
end
