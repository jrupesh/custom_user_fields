require File.expand_path('../../test_helper', __FILE__)

class CustomFieldsControllerTest < ActionController::TestCase

	fixtures :users, :roles, :projects, :members, :member_roles, :groups_users, :custom_fields, :custom_fields_projects

  def setup
    @request.session[:user_id] = 1
  end

  def test_new_issue_custom_field
  	@request.session[:user_id] = 1
    get :new, :type => 'IssueCustomField'
    assert_response :success
    assert_template 'new'
    assert_select 'form#custom_field_form' do
      assert_select 'select#custom_field_field_format[name=?]', 'custom_field[field_format]' do
        assert_select 'option[value=user]', :text => 'User'
      end
    end
  end

  test "Role of and Group of options" do
    get :new, :type => 'IssueCustomField', :custom_field => {:field_format => 'user'}
    assert_response :success
    assert_select '[name=?]', 'custom_field[default_value]', 0
    assert_select '[name=?]', 'custom_field[role_of]', 1
    assert_select '[name=?]', 'custom_field[group_of]', 1
    assert_select('select#custom_field_role_of').first['All']
    assert_select('select#custom_field_group_of').first['None']

    assert_select 'select#custom_field_role_of' do
      assert_select "option", :count => ( Role.count + 1 )
    end

    assert_select 'select#custom_field_group_of' do
      assert_select "option", :count => ( Group.count + 1 )
    end
  end
end
