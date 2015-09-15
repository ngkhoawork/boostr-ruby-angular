I# Boostr

* Rails 4.2.3
* Ruby 2.2.2
* Angular 1.x
* CoffeeScript
* Haml
* Bootstrap

## Testing

boostr tests are written as a combination of specs, features (in Selenium/Capybara), and jasmine JavaScript tests. To run the specs you can simply

    rake

All of the necessary items should be installed for you.

## Trying things out

To setup the database you need to copy over the database.yml:

    cp congig/database.yml.example config/database.yml

Then setup the database:

    rake db:setup

Then run rails:

    rails s

At this point you should have a fully setup seeded database and can open the browser to [http://localhost:3000](http://localhost:3000)

To sign in you can use one of the following logins (which are created in the seed data):

  - **company@example.com** - The most complete user, able to see all of the objects in the default company
  - **leader@example.com** - A team lead that can see across many objects in the default company
  - **west-coast-member@example.com** - A team member who is part of one deal
  - **east-coast-member@example.com** - A team member who is part of one deal
  - **shark@example.com** - A team member who is part of one deal and has revenue items
  - **admin@example.com** - A super admin that can see the main admin pages but not much else

In all cases the password is `password`.

