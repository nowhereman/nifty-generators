require File.dirname(__FILE__) + '/../spec_helper'
 
describe <%= plural_class_name %>Controller do
  fixtures :all
  integrate_views
  
  before(:each) do
    @<%= singular_name %> = <%= class_name %>.make
    <%= class_name %>.stub!(:new).and_return(@<%= singular_name %>)
    <%= class_name %>.stub!(:find).and_return(@<%= singular_name %>)
    <%= class_name %>.stub!(:all).and_return([@<%= singular_name %>])
  end
  
  <%= controller_methods 'tests/rspec/actions_rspec_mocks' %>
  <%= controller_methods 'tests/rspec/actions_shared' %>
end
