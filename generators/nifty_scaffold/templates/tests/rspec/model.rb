require File.dirname(__FILE__) + '/../spec_helper'
<%- if options[:machinist] -%>
# TODO Create a <%= class_name %> blueprint in spec/support/blueprints.rb

<%- end -%>
describe <%= class_name %> do
  # TODO Remove this example and fill in with real specs
  it "should be valid" do
  <%- if options[:machinist] -%>
    <%= class_name %>.make_unsaved.should be_valid
  <%- else -%>
    <%= class_name %>.new.should be_valid
  <%- end -%>
  end
end
