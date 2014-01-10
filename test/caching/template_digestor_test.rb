# -*- coding: utf-8 -*-
require 'test_helper'

class TemplateDigestorTest < MiniTest::Spec
  include Cell::TestCase::TestMethods

  before :each do
    # ActionController::Base.cache_store.clear
    # ActionController::Base.perform_caching = true
    @cell = cell(:bassist)
    @lookup_context = @cell.lookup_context
    @class = Cell::Caching::TemplateDigestor
  end

  after :each do
    @class.cache_store.clear
  end

  describe '.digest' do
    it "returns digest when template is present" do
      template = @lookup_context.find('bassist/play.html', [], false)
      digest = Digest::MD5.hexdigest(template.source)

      assert_equal @class.digest('bassist/play', :html, @lookup_context), digest
    end

    it "returns digest for the template with correct format" do
      template = @lookup_context.find('bassist/play.js', [], false)
      digest = Digest::MD5.hexdigest(template.source)

      assert_equal @class.digest('bassist/play', :js, @lookup_context), digest
    end

    it "returns differnet digest for a template with same name but differnet format" do
      template = @lookup_context.find('bassist/play.js', [], false)
      digest = Digest::MD5.hexdigest(template.source)

      assert @class.digest('bassist/play', :html, @lookup_context) != digest
    end

    it "returns empty string when template missing" do
      assert_equal @class.digest('bassist/groove', :html, @lookup_context), ""
    end
  end
end
