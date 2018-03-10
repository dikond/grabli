require "grabli/version"
require "pundit"

class Grabli
  #
  # Collect allowed policy permissions for the given user.
  #
  # @param user [Object] user object your policy work with
  # @param subject [Symbol, Object] subject object your policy work with
  # @return [Array<Symbol>] array of allowed policy permission
  # @example
  #
  #   Grabli.new.collect(@user, @company)
  #   #=> [:create?, :update?, :manage_occupied?]
  #
  #   Grabli.new.collect(@user, :company)
  #   #=> [:create?]
  #
  def collect(user, subject)
    policy_class(subject)
      .public_instance_methods(false)
      .reject! { |n| n =~ /permitted_attributes/ }
      .each_with_object([]) do |permission, collection|
        # allows to collect permissions without subject, for more @see Intruder
        isubject = subject.is_a?(Symbol) ? Intruder.new(false) : subject
        policy = policy_class(subject).new(user, isubject)

        collection << permission if allowed? policy, permission
      end
      .sort
  end

  # Check whether certain permission is allowed.
  #
  # @param policy [ApplicationPolicy] instantiated policy
  # @param permission [Symbol] permission name
  # @return [Boolen, Object] true or false in case subject intruded
  #   or whatever you policy permission returns
  # @example
  #
  #   policy = Pundit.policy(@user, @company)
  #   Grabli.new.allowed?(policy, :create?)
  #   #=> true
  #
  def allowed?(policy, permission)
    result = policy.public_send(permission)
    return !policy.record.intruded if policy.record.is_a?(Intruder)
    result
  end

  private def policy_class(record)
    Pundit::PolicyFinder.new(record).policy
  end

  #
  # When no subject specified by the user or the subject is a Symbol,
  # we pass that object as a subject.
  #
  # If the subject isn't used it means we can add this permission as allowed.
  # If it's used, CURRENTLY, we assume that the given permission isn't allowed.
  #
  # TODO: delegate to the original subject if it was given
  #       and intercept NoMethodError
  #
  Intruder = Struct.new(:intruded) do
    def method_missing(*)
      self[:intruded] = true
      self
    end
  end
end
