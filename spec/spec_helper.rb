require "bundler/setup"
require "grabli"

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
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

class User < Struct.new(:admin, :invited_by)
end
