# -*- coding: utf-8 -*-
require 'test_helper'

class TemplateFinderTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  before :each do
    # ActionController::Base.cache_store.clear
    # ActionController::Base.perform_caching = true
    @bassist = cell(:bassist)
    @bad_guitarist = cell(:bad_guitarist)
    @class = Cell::Caching::TemplateFinder
  end

  describe '.find' do
    it "returns template instance when template is present" do
      template = @bassist.lookup_context.find('bassist/promote', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('promote', @bassist).source, template.source
    end

    it "returns digest for the template with format html by default" do
      template = @bassist.lookup_context.find('bassist/play.html', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('play', @bassist).source, template.source
    end

    it "returns digest for the template with correct format" do
      template = @bassist.lookup_context.find('bassist/play.js', [], false)
      assert template.formats.include?(:js), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('play', @bassist, format: :js).source, template.source
    end

    it "returns digest for the template with locale" do
      template = @bassist.lookup_context.find('bassist/yell.en.html', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('yell', @bassist, format: :html).source, template.source
    end

    it "returns digest for super class's template from inherited cell" do
      template = @bad_guitarist.lookup_context.find('bassist/promote', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('promote', @bad_guitarist, format: :html).source, template.source
    end

    it "returns digest for its own template from inherited cell if it has" do
      template = @bad_guitarist.lookup_context.find('bad_guitarist/_dii', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('_dii', @bad_guitarist, format: :html).source, template.source
    end

    it "returns nil when template missing" do
      assert_raises (ActionView::MissingTemplate) { @class.find('groove', @bassist) }
    end
  end
end
