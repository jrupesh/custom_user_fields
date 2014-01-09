require File.expand_path('../../test_helper', __FILE__)

class CustomFieldsTest < ActionController::IntegrationTest

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers,
           :groups_users

  def test_issue_with_user_custom_field_role_of
    @field = IssueCustomField.create!(:name => 'RoleOfTester', :field_format => 'user',
    																	:is_for_all => true, :trackers => [Tracker.find(1)])
    role = Role.find(2)
    @field.role_of = role.id
    @field.save

    project = Project.find(1)
    user = User.find(7)

    Role.anonymous.add_permission! :add_issues, :edit_issues
    Member.create!(:principal => user, :project => project, :roles => [role])

    users = project.users_by_role[role]
    role_tester = users.first

    # # Issue form
    get '/projects/ecookbook/issues/new'
    assert_response :success
    assert_tag :select,
      :attributes => {:name => "issue[custom_field_values][#{@field.id}]"},
      :children => {:count => (users.size + 1)}, # +1 for blank value
      :child => {
        :tag => 'option',
        :attributes => {:value => role_tester.id.to_s},
        :content => role_tester.name
      }

    # # Create issue
    assert_difference 'Issue.count' do
      post '/projects/ecookbook/issues',
        :issue => {
          :tracker_id => '1',
          :priority_id => '4',
          :subject => 'Issue with user custom field',
          :custom_field_values => {@field.id.to_s => users.first.id.to_s}
        }
    end
    issue = Issue.first(:order => 'id DESC')
    assert_response 302

    # # Issue view
    follow_redirect!
    assert_tag :th,
      :content => /RoleOfTester/,
      :sibling => {
        :tag => 'td',
        :content => role_tester.name
      }
    assert_tag :select,
      :attributes => {:name => "issue[custom_field_values][#{@field.id}]"},
      :children => {:count => (users.size + 1)}, # +1 for blank value
      :child => {
        :tag => 'option',
        :attributes => {:value => role_tester.id.to_s, :selected => 'selected'},
        :content => role_tester.name
      }

    # # Update issue
    new_role_tester = users[1]
    assert_difference 'Journal.count' do
      put "/issues/#{issue.id}",
        :notes => 'Updating custom field',
        :issue => {
          :custom_field_values => {@field.id.to_s => new_role_tester.id.to_s}
        }
    end
    assert_response 302

    # Issue view
    follow_redirect!
    assert_tag :content => 'RoleOfTester',
      :ancestor => {:tag => 'ul', :attributes => {:class => /details/}},
      :sibling => {
        :content => role_tester.name,
        :sibling => {
          :content => new_role_tester.name
        }
      }
  end

  def test_issue_with_user_custom_field_group_of
    @field = IssueCustomField.create!(:name => 'GroupOfTester', :field_format => 'user',
    																	:is_for_all => true, :trackers => [Tracker.find(1)])

    group = Group.first
    @field.group_of = group.id
    @field.save

    project = Project.find(1)
    user = User.find(7)
    group.users << user
    group.save
    group.reload

    Role.anonymous.add_permission! :add_issues, :edit_issues

    role = Role.find(3)
    group.users.each { |u| Member.create!(:principal => u, :project => project, :roles => [role]) }

    group_tester = group.users.first

    # # Issue form
    get '/projects/ecookbook/issues/new'
    assert_response :success
    assert_tag :select,
      :attributes => {:name => "issue[custom_field_values][#{@field.id}]"},
      :children => {:count => (group.users.size + 1)}, # +1 for blank value
      :child => {
        :tag => 'option',
        :attributes => {:value => group_tester.id.to_s},
        :content => group_tester.name
      }

    # # Create issue
    assert_difference 'Issue.count' do
      post '/projects/ecookbook/issues',
        :issue => {
          :tracker_id => '1',
          :priority_id => '4',
          :subject => 'Issue with user custom field',
          :custom_field_values => {@field.id.to_s => group.users.first.id.to_s}
        }
    end
    issue = Issue.first(:order => 'id DESC')
    assert_response 302

    # # Issue view
    follow_redirect!
    assert_tag :th,
      :content => /GroupOfTester/,
      :sibling => {
        :tag => 'td',
        :content => group_tester.name
      }
    assert_tag :select,
      :attributes => {:name => "issue[custom_field_values][#{@field.id}]"},
      :children => {:count => (group.users.size + 1)}, # +1 for blank value
      :child => {
        :tag => 'option',
        :attributes => {:value => group_tester.id.to_s, :selected => 'selected'},
        :content => group_tester.name
      }

    # # Update issue
    new_group_tester = group.users[1]
    assert_difference 'Journal.count' do
      put "/issues/#{issue.id}",
        :notes => 'Updating custom field',
        :issue => {
          :custom_field_values => {@field.id.to_s => new_group_tester.id.to_s}
        }
    end
    assert_response 302

    # Issue view
    follow_redirect!
    assert_tag :content => 'GroupOfTester',
      :ancestor => {:tag => 'ul', :attributes => {:class => /details/}},
      :sibling => {
        :content => group_tester.name,
        :sibling => {
          :content => new_group_tester.name
        }
      }
  end
end