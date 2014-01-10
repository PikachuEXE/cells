# -*- coding: utf-8 -*-
require 'test_helper'

class TemplateFinderTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  before :each do
    # ActionController::Base.cache_store.clear
    # ActionController::Base.perform_caching = true
    @cell = cell(:bassist)
    @lookup_context = @cell.lookup_context
    @class = Cell::Caching::TemplateFinder
  end

  describe '.find' do
    it "returns template instance when template is present" do
      template = @lookup_context.find('bassist/promote', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('promote', @cell).source, template.source
    end

    it "returns digest for the template with format html by default" do
      template = @lookup_context.find('bassist/play.html', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('play', @cell).source, template.source
    end

    it "returns digest for the template with correct format" do
      template = @lookup_context.find('bassist/play.js', [], false)
      assert template.formats.include?(:js), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('play', @cell, format: :js).source, template.source
    end

    it "returns digest for the template with locale" do
      template = @lookup_context.find('bassist/yell.en.html', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.find('yell', @cell, format: :html).source, template.source
    end

    it "returns digest for the template from inherited cell" do
      template = @lookup_context.find('bassist/promote', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      puts cell(:bad_guitarist)._prefixes

      assert_equal @class.find('promote', cell(:bad_guitarist), format: :html).source, template.source
    end

    it "returns nil when template missing" do
      assert_nil @class.find('groove', @cell)
    end
  end
end
