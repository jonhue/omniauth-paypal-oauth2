# OmniAuth PayPal OAuth2 Strategy

[![Gem Version](https://badge.fury.io/rb/omniauth-paypal-oauth2.svg)](https://badge.fury.io/rb/omniauth-paypal-oauth2) ![Travis](https://travis-ci.org/jonhue/omniauth-paypal-oauth2.svg?branch=master)

Strategy to authenticate with PayPal via OmniAuth.

Get your API key at: https://developer.paypal.com/developer/applications/ in the section **RESTApps**. Note the Client ID and the Client Secret.

**Note**: You generate separate keys for development (sandbox) and production (live) with each application you register.
Use the [config Gem](https://rubygems.org/gems/config) to organize your keys and keep them safe.

For more details, read the PayPal docs: https://developer.paypal.com/docs/integration/direct/identity/

---

## Table of Contents

* [Installation](#installation)
* [Usage](#usage)
  * [PayPal API Setup](#paypal-api-setup)
  * [Rails middleware](#rails-middleware)
  * [Devise](#Devise)
  * [Configuration](#configuration)
  * [Auth hash](#auth-hash)
* [Testing](#testing)
* [To Do](#to-do)
* [Contributing](#contributing)
  * [Semantic versioning](#semantic-versioning)

---

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-paypal-oauth2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-paypal-oauth2

If you always want to be up to date fetch the latest from GitHub in your `Gemfile`:

```ruby
gem 'omniauth-paypal-oauth2', github: 'jonhue/omniauth-paypal-oauth2'
```

---

## Usage

### PayPal API Setup

* Go to 'https://developer.paypal.com/developer/applications/'
* Select your project.
* Scroll down to 'APP SETTINGS' for each 'SANDBOX' and 'LIVE'.
* Set `<YOURDOMAIN>/users/auth/paypal_oauth2/callback` as Return URL.
* Make sure "Log In with PayPal" is enabled and Save.
* Go to Credentials, then select the "OAuth consent screen" tab on top, and provide an 'EMAIL ADDRESS' and a 'PRODUCT NAME'
* Wait 10 minutes for changes to take effect.

### Rails middleware

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :paypal_oauth2, ENV['PAYPAL_CLIENT_ID'], ENV['PAYPAL_CLIENT_SECRET']
end
```

You can now access the OmniAuth PayPal OAuth2 URL: `/auth/paypal_oauth2`

**Note**: While developing your application, if you change the scope in the initializer you will need to restart your app server. Remember that either the 'email' or 'profile' scope is required!

### Devise

First define your application id and secret in `config/initializers/devise.rb`. Do not use the snippet mentioned in the [Usage](https://github.com/jonhue/omniauth-paypal-oauth2#usage) section.

```ruby
require 'omniauth-paypal-oauth2'
config.omniauth :paypal_oauth2, 'PAYPAL_CLIENT_ID', 'PAYPAL_CLIENT_SECRET'
```

Then add the following to 'config/routes.rb' so the callback routes are defined.

```ruby
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```

Make sure your model is omniauthable. Generally this is `'/app/models/user.rb'`

```ruby
devise :omniauthable, omniauth_providers: [:paypal_oauth2]
```

Then make sure your callbacks controller is setup.

```ruby
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def paypal_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'PayPal')
      sign_in_and_redirect(@user, event: :authentication)
    else
      session['devise.paypal_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
```

and bind to or create the user

```ruby
def self.from_omniauth(access_token)
  data = access_token.info
  user = User.where(email: data['email']).first

  # Uncomment the section below if you want users to be created if they don't exist
  # unless user
  #   user = User.create(name: data['name'],
  #      email: data['email'],
  #      password: Devise.friendly_token[0,20]
  #   )
  # end
  user
end
```

For your views you can login using:

```erb
<%= link_to 'Sign in with PayPal', user_paypal_oauth2_omniauth_authorize_path %>

<%# Devise prior 4.1.0: %>
<%= link_to 'Sign in with PayPal', user_omniauth_authorize_path(:paypal_oauth2) %>
```

An overview is available at https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

### Configuration

If you click from your [Applications Dashboard](https://developer.paypal.com/developer/applications/) in your Application on "Advanced Options" in the "APP SETTINGS" section and "Log In with PayPal" subsection, you can configure several options:

* `Basic authentication`: The unique identifier PPID (PayPal ID) is provided. No additional customer information. **Not customizable**.

* `Personal Information`:
    * `Full name`: Permits the Name of the customer.
    * `Date of birth`: Permits the date of birth of the customer.
    * `Age range`: Permits an approximate age range of the customer.

* `Address Information`:
    * `Email address`: Permits the email address of the customer.
    * `Street address`: Permits the street address of the customer (Street name, House number).
    * `City`: Permits the city name where the customer resides.
    * `State`: Permits the state in which the city is located.
    * `Country`: Permits the country in which both state and city are located.
    * `Zip code`: Permits the Zip code of the customer.
    * `Phone`: Permits the phone number of the customer.

* `Account Information`:
    * `Account status (verified)`: Permits a boolean which indicates whether the customer is verified by PayPal or not.
    * `Account type`: Permits a string which indicates the account type of the PayPal customer (e.g.: PERSONAL, BUSINESS).
    * `Account creation date`: Permits the date on which the PayPal account got created.
    * `Time zone`: Permits the time zone in which the PayPal customer is located.
    * `Locale`: Permits a locale string which indicates where the PayPal customer is.
    * `Language`: Permits the language the customer uses on PayPal.

### Auth Hash

Here's an example of an authentication hash available in the callback by accessing `request.env['omniauth.auth']`:

```ruby
{
  provider: 'paypal',
  uid: 'bathjJwvdhKjgfgh8Jd745J7dh5Qkgflbnczd65dfnw',
  info: {
    name: 'John Smith',
    email: 'example@example.com',
    first_name: 'John',
    last_name: 'Smith',
    given_name: 'John',
    family_name: 'Smith',
    location: 'Moscow',
    phone: '71234567890'
  },
  credentials: {
    token: 'token',
    refresh_token: 'refresh_token',
    expires_at: 1355082790,
    expires: true
  },
  extra: {
    account_creation_date: '2008-04-21',
    account_type: 'PERSONAL',
    user_id: 'https://www.paypal.com/webapps/auth/identity/user/bathjJwvdhKjgfgh8Jd745J7dh5Qkgflbnczd65dfnw',
    address: {
      country: 'US',
      locality: 'San Jose',
      postal_code: '95131',
      region: 'CA',
      street_address: '1 Main St'
    },
    language: 'en_US',
    locale: 'en_US',
    verified_account: true,
    zoneinfo: 'America/Los_Angeles',
    age_range: '31-35',
    birthday: '1982-01-01'
  }
}
```

For more details see the PayPal [List Of Attributes](https://developer.paypal.com/webapps/developer/docs/integration/direct/log-in-with-paypal/detailed/#attributes).

---

## Testing

1. Fork this repository
2. Clone your forked git locally
3. Install dependencies

    `$ bundle install`

4. Run specs

    `$ bundle exec rspec`

5. Run RuboCop

    `$ bundle exec rubocop`

---

## To Do

We use [GitHub projects](https://github.com/jonhue/omniauth-paypal-oauth2/projects/1) to coordinate the work on this project.

To propose your ideas, initiate the discussion by adding a [new issue](https://github.com/jonhue/omniauth-paypal-oauth2/issues/new).

---

## Contributing

We hope that you will consider contributing to OmniAuth PayPal OAuth2 Strategy. Please read this short overview for some information about how to get started:

[Learn more about contributing to this repository](https://github.com/jonhue/omniauth-paypal-oauth2/blob/master/CONTRIBUTING.md), [Code of Conduct](https://github.com/jonhue/omniauth-paypal-oauth2/blob/master/CODE_OF_CONDUCT.md)

### Semantic Versioning

omniauth-paypal-oauth2 follows Semantic Versioning 2.0 as defined at http://semver.org.
