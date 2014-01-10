# -*- coding: utf-8 -*-
require 'test_helper'

class TemplateDigestorTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  before :each do
    # ActionController::Base.cache_store.clear
    # ActionController::Base.perform_caching = true
    @bassist = cell(:bassist)
    @bad_guitarist = cell(:bad_guitarist)
    @class = Cell::Caching::TemplateDigestor
  end

  after :each do
    @class.cache_store.clear
  end

  describe '.digest' do
    it "returns template instance when template is present" do
      template = @bassist.lookup_context.find('bassist/promote', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"
      begin
        @class.digest('promote', @bassist)
      rescue => e
        puts e.backtrace
      end

      # assert_equal @class.digest('promote', @bassist), Digest::MD5.hexdigest(template.source)
    end

    it "returns digest for the template with format html by default" do
      template = @bassist.lookup_context.find('bassist/play.html', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.digest('play', @bassist), Digest::MD5.hexdigest(template.source)
    end

    it "returns digest for the template with correct format" do
      template = @bassist.lookup_context.find('bassist/play.js', [], false)
      assert template.formats.include?(:js), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.digest('play', @bassist, format: :js), Digest::MD5.hexdigest(template.source)
    end

    it "returns digest for the template with locale" do
      template = @bassist.lookup_context.find('bassist/yell.en.html', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.digest('yell', @bassist, format: :html), Digest::MD5.hexdigest(template.source)
    end

    it "returns digest for super class's template from inherited cell" do
      template = @bad_guitarist.lookup_context.find('bassist/promote', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.digest('promote', @bad_guitarist, format: :html), Digest::MD5.hexdigest(template.source)
    end

    it "returns digest for its own template from inherited cell if it has" do
      template = @bad_guitarist.lookup_context.find('bad_guitarist/_dii', [], false)
      assert template.formats.include?(:html), "prepared template should have correct format but with #{template.formats}"

      assert_equal @class.digest('_dii', @bad_guitarist, format: :html), Digest::MD5.hexdigest(template.source)
    end

    it "returns nil when template missing" do
      assert_equal @class.digest('groove', @bassist), ''
    end
  end
end
