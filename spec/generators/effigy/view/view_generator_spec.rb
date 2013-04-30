require 'spec_helper'
require 'generators/effigy/view/view_generator'

describe Effigy::Generators::ViewGenerator do
  destination File.join(PROJECT_ROOT, 'tmp')
  before { prepare_destination }

  it 'generates an action view and template with the given name' do
    run_generator %w(users create)

    view = file('app/views/users/create.html.effigy')
    view.should exist
    view.should contain('class UsersCreateView < Effigy::Rails::View')
    view.should contain('app/templates/users/create.html')

    template = file('app/templates/users/create.html')
    template.should exist
    template.should contain('UsersCreateView')
    template.should contain('Edit me at app/templates/users/create.html')
    template.
      should contain('Edit my view at app/views/users/create.html.effigy')
  end

   it 'generates a layout view and template' do
     run_generator %w(layouts narrow)

     view = file('app/views/layouts/narrow.html.effigy')
     view.should exist
     view.should contain('class NarrowLayout < Effigy::Rails::View')
     view.should contain('app/templates/layouts/narrow.html')

     template = file('app/templates/layouts/narrow.html')
     template.should exist
     template.should contain('NarrowLayout')
     template.should contain('Edit me at app/templates/layouts/narrow.html')
     template.
       should contain('Edit my view at app/views/layouts/narrow.html.effigy')
   end
end
