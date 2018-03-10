# Grabli

Hola :v:

The very specific goal of this gem is to extract pundit policy permissions to something serializable... like a ruby array! Why do you need that? To tell the front-end application or API consumer what you think of the current user, hehe :smirk: As a bonus, I find it easier to write unit tests for policies. But to have a dependency on third-party gems for unit tests, even as awesome as this one, may be undesirable.

## Usage

With a given `UserPolicy` (e.g. the one defined in `/spec/spec_helper.rb`) you can do:

```ruby
require 'grabli'

Grabli.new.collect(@user, @company)
# => [:create?, :update?]

Grabli.new.collect(@user, :company)
# => [:create?]
```

Let's say your app have a public Rest API. It may look like:

```ruby
require 'grabli'

class Api::UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize @user

    permissions = Grabli.new.collect(current_user, @user)

    render json: { user: @user.to_json, permissions: permissions }
  end
end
```

You can then create a helper and use it across your app, for example:

```ruby
# /app/controllers/application_controller.rb
require 'grabli'

class ApplicationController
  def collect_permissions_for(subject)
    Grabli.new.collect(current_user, subject)
  end
  helper_method :collect_permissions_for
end


# /app/controllers/api/users_controller.rb
class Api::UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize @user

    render json: { user: @user.to_json, permissions: collect_permissions_for(@user) }
  end
end
```

## Further plans

1) Improve cases when subject is a `Symbol`

Since pundit policy doesn't limit the subject types it can be anything, even a `Symbol`.

Make `Intruder` a bit more clever proxy object which delegates to the subject and intercepts `NoMethodError` for cases when `Symbol` subject mean "no subject".

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grabli.
