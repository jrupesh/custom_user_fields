require File.expand_path('../../test_helper', __FILE__)

class CustomFieldTest < ActiveSupport::TestCase

	fixtures :users, :groups_users, :custom_fields, :roles

  def test_user_role_of
    f = CustomField.new(:name => "RoleOf_CF", :field_format => 'user')
    assert f.respond_to?(:role_of)
    f.role_of = Role.last
    assert f.save
  end

  def test_user_group_of
    f = CustomField.new(:name => "GroupOf_CF", :field_format => 'user')
    assert f.respond_to?(:group_of)
    f.group_of = Group.last
    assert f.save
  end
end
