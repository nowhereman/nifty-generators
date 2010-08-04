require File.dirname(__FILE__) + '/../spec_helper'
 
describe <%= plural_class_name %>Controller do
  fixtures :all
  integrate_views
  
  before(:each) do
  <%- if options[:machinist] && options[:declarative_authorization] -%>
    # Uncomment to enable session and authorization rules
#    activate_session

    # <%= class_name %> factory and stub methods
      # TODO You should add at least one validation in your model.
      # E.g. validates_presence_of :<%= attributes.first.name %>
      @<%= singular_name %>_new = <%= class_name %>.make_unsaved
      @<%= singular_name %>_bad = <%= class_name %>.make_unsaved(<%= attributes.map { |a| ":#{a.name} => nil" }.join(', ') %>)
      @<%= singular_name %> = @<%= singular_name %>_new.clone
      @<%= singular_name %>.save
      @<%= plural_name %> = [ @<%= singular_name %> ]
      <%= class_name %>.stub!(:first).and_return(@<%= singular_name %>)
      <%= class_name %>.stub!(:find).with(kind_of(Numeric)).and_return(@<%= singular_name %>)
      <%= class_name %>.stub!(:find).with(kind_of(String)).and_return(@<%= singular_name %>)
#      <%= class_name %>.stub!(:find).with(nil).and_return(@<%= singular_name %>)
      <%= class_name %>.stub!(:find).with(:first, anything()).and_return(@<%= singular_name %>)
      <%= class_name %>.stub!(:find).with(:all, anything()).and_return(@<%= plural_name %>)
      <%= class_name %>.stub!(:all).and_return(@<%= plural_name %>)
  <%- else -%>
    @<%= singular_name %> = <%= class_name %>.make
    @<%= plural_name %> = [@<%= singular_name %>]
    <%= class_name %>.stub!(:new).and_return(@<%= singular_name %>)
    <%= class_name %>.stub!(:find).and_return(@<%= singular_name %>)
    <%= class_name %>.stub!(:all).and_return([@<%= singular_name %>])
  <%- end -%>
  end

  <%- if options[:machinist] -%>
  <%= controller_methods 'tests/rspec/actions_rspec_mocks_with_machinist' %>
  <%- else -%>
  <%= controller_methods 'tests/rspec/actions_rspec_mocks' %>
  <%- end -%>

  <%= controller_methods 'tests/rspec/actions_shared' %>

end