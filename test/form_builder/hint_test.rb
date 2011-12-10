require 'test_helper'

# Tests for f.hint
class HintTest < ActionView::TestCase
  def with_hint_for(object, *args)
    with_concat_form_for(object) do |f|
      f.hint(*args)
    end
  end

  test 'hint should not be generated by default' do
    with_hint_for @user, :name
    assert_no_select 'span.hint'
  end

  test 'hint should be generated with optional text' do
    with_hint_for @user, :name, :hint => 'Use with care...'
    assert_select 'span.hint', 'Use with care...'
  end

  test 'hint should be generated cleanly with optional text' do
    with_hint_for @user, :name, :hint => 'Use with care...'
    assert_no_select 'span.hint[hint]'
    assert_no_select 'span.hint[hint_html]'
  end

  test 'hint uses the current component tag set' do
    with_hint_for @user, :name, :hint => 'Use with care...', :hint_tag => :p
    assert_select 'p.hint', 'Use with care...'
  end

  test 'hint should be able to pass html options' do
    with_hint_for @user, :name, :hint => 'Yay!', :id => 'hint', :class => 'yay'
    assert_select 'span#hint.hint.yay'
  end

  # Without attribute name

  test 'hint without attribute name' do
    with_hint_for @validating_user, 'Hello World!'
    assert_select 'span.hint', 'Hello World!'
  end

  test 'hint without attribute name should generate component tag with a clean HTML' do
    with_hint_for @validating_user, 'Hello World!'
    assert_no_select 'span.hint[hint]'
    assert_no_select 'span.hint[hint_html]'
  end

  test 'hint without attribute name uses the current component tag set' do
    with_hint_for @user, 'Hello World!', :hint_tag => :p
    assert_no_select 'p.hint[hint]'
    assert_no_select 'p.hint[hint_html]'
    assert_no_select 'p.hint[hint_tag]'
  end

  test 'hint without attribute name should be able to pass html options' do
    with_hint_for @user, 'Yay', :id => 'hint', :class => 'yay'
    assert_select 'span#hint.hint.yay', 'Yay'
  end

  # I18n

  test 'hint should use i18n based on model, action, and attribute to lookup translation' do
    store_translations(:en, :simple_form => { :hints => { :user => {
      :edit => { :name => 'Content of this input will be truncated...' }
    } } }) do
      with_hint_for @user, :name
      assert_select 'span.hint', 'Content of this input will be truncated...'
    end
  end

  test 'hint should use i18n with model and attribute to lookup translation' do
    store_translations(:en, :simple_form => { :hints => { :user => {
      :name => 'Content of this input will be capitalized...'
    } } }) do
      with_hint_for @user, :name
      assert_select 'span.hint', 'Content of this input will be capitalized...'
    end
  end

  test 'hint should not use i18n just with attribute to lookup translation if it is a model' do
    store_translations(:en, :simple_form => { :hints => {
      :company => { :name => 'Nome' }
    } } ) do
      with_hint_for @user, :company, :reflection => Association.new(Company, :company, {})
      assert_no_select 'span.hint'
    end
  end

  test 'hint should use i18n just with attribute to lookup translation' do
    store_translations(:en, :simple_form => { :hints => {
      :defaults => {:name => 'Content of this input will be downcased...'}
    } }) do
      with_hint_for @user, :name
      assert_select 'span.hint', 'Content of this input will be downcased...'
    end
  end

  test 'hint should use i18n with lookup for association name' do
    store_translations(:en, :simple_form => { :hints => {
      :user => { :company => 'My company!' }
    } } ) do
      with_hint_for @user, :company_id, :as => :string, :reflection => Association.new(Company, :company, {})
      assert_select 'span.hint', /My company!/
    end
  end

  # No object

  test 'hint should generate properly when object is not present' do
    with_hint_for :project, :name, :hint => 'Test without object'
    assert_select 'span.hint', 'Test without object'
  end

  # Custom wrappers

  test 'hint with custom wrappers works' do
    swap_wrapper do
      with_hint_for @user, :name, :hint => "can't be blank"
      assert_select 'span.omg_hint', "can't be blank"
    end
  end
end