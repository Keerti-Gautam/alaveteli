# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
load "lib/data_export.rb"

describe DataExport do

  let(:described_class) { DataExport }

  describe ".exportable_requests" do

    let(:cut_off) { Date.today + 1 }

    it "includes eligible requests " do
      request = FactoryGirl.create(:info_request)
      exportable = described_class.exportable_requests(cut_off)

      expect(exportable).to include(request)
    end

    it "does not include hidden requests" do
      hidden = FactoryGirl.create(:info_request, :prominence => 'hidden')
      exportable = described_class.exportable_requests(cut_off)

      expect(exportable).to_not include(hidden)
    end

    it "does not include requests created after the cut_off date" do
      request = FactoryGirl.create(:info_request)
      exportable = described_class.exportable_requests(Date.today)

      expect(exportable).to_not include(request)
    end

    it "does not include embargoed requests" do
      embargoed = FactoryGirl.create(:embargoed_request)
      exportable = described_class.exportable_requests(cut_off)

      expect(exportable).to_not include(embargoed)
    end

  end

  describe ".exportable_incoming_messages" do

    let(:cut_off) { Date.today + 1 }

    it "includes eligible messages" do
      incoming = FactoryGirl.create(:incoming_message)
      exportable = described_class.exportable_incoming_messages(cut_off)

      expect(exportable).to include(incoming)
    end

    it "does not include hidden messages" do
      hidden = FactoryGirl.create(:incoming_message, :prominence => 'hidden')
      exportable = described_class.exportable_incoming_messages(cut_off)

      expect(exportable).to_not include(hidden)
    end

    it "does not include messages created after the cut_off date" do
      incoming = FactoryGirl.create(:incoming_message)
      exportable = described_class.exportable_incoming_messages(Date.today)

      expect(exportable).to_not include(incoming)
    end

    it "does not include messages belonging to hidden requests" do
      hidden_request = FactoryGirl.create(:info_request,
                                          :prominence => 'hidden')
      message = FactoryGirl.create(:incoming_message,
                                   :info_request => hidden_request)

      exportable = described_class.exportable_incoming_messages(cut_off)
      expect(exportable).to_not include(message)
    end

    it "does not include messages belonging to embargoed requests" do
      embargoed = FactoryGirl.create(:embargoed_request)
      message = FactoryGirl.create(:incoming_message,
                                   :info_request => embargoed)

      exportable = described_class.exportable_incoming_messages(cut_off)
      expect(exportable).to_not include(message)
    end

  end

  describe ".exportable_outgoing_messages" do

    let(:cut_off) { Date.today + 1 }

    it "includes eligible messages" do
      outgoing = FactoryGirl.create(:initial_request)
      exportable = described_class.exportable_outgoing_messages(cut_off)

      expect(exportable).to include(outgoing)
    end

    it "does not include hidden messages" do
      hidden = FactoryGirl.create(:initial_request, :prominence => 'hidden')
      exportable = described_class.exportable_outgoing_messages(cut_off)

      expect(exportable).to_not include(hidden)
    end

    it "does not include messages created after the cut_off date" do
      outgoing = FactoryGirl.create(:initial_request)
      exportable = described_class.exportable_outgoing_messages(Date.today)

      expect(exportable).to_not include(outgoing)
    end

    it "does not include messages belonging to hidden requests" do
      hidden_request = FactoryGirl.create(:info_request,
                                          :prominence => 'hidden')
      message = FactoryGirl.create(:initial_request,
                                   :info_request => hidden_request)

      exportable = described_class.exportable_outgoing_messages(cut_off)
      expect(exportable).to_not include(message)
    end

    it "does not include messages belonging to embargoed requests" do
      embargoed = FactoryGirl.create(:embargoed_request)
      message = FactoryGirl.create(:initial_request,
                                   :info_request => embargoed)

      exportable = described_class.exportable_outgoing_messages(cut_off)
      expect(exportable).to_not include(message)
    end

  end

  describe ".exportable_foi_attachments" do

    let(:cut_off) { Date.today + 1 }

    it "includes eligible attachments" do
      incoming =  FactoryGirl.create(:incoming_message)
      attachment = FactoryGirl.create(:html_attachment,
                                      :incoming_message => incoming)
      exportable = described_class.exportable_foi_attachments(cut_off)

      expect(exportable).to include(attachment)
    end

    it "does not include attachments of hidden messages" do
      incoming =  FactoryGirl.create(:incoming_message, :prominence => 'hidden')
      attachment = FactoryGirl.create(:html_attachment,
                                      :incoming_message => incoming)
      exportable = described_class.exportable_foi_attachments(cut_off)

      expect(exportable).to_not include(attachment)
    end

    it "does not include attachments of messages created after the cut_off" do
      incoming = FactoryGirl.create(:incoming_message)
      attachment = FactoryGirl.create(:html_attachment,
                                      :incoming_message => incoming)
      exportable = described_class.exportable_foi_attachments(Date.today)

      expect(exportable).to_not include(attachment)
    end

    it "does not include attachments of messages belonging to hidden requests" do
      hidden_request = FactoryGirl.create(:info_request,
                                          :prominence => 'hidden')
      incoming = FactoryGirl.create(:incoming_message,
                                   :info_request => hidden_request)
      attachment = FactoryGirl.create(:html_attachment,
                                      :incoming_message => incoming)

      exportable = described_class.exportable_foi_attachments(cut_off)
      expect(exportable).to_not include(attachment)
    end

    it "does not include attachments related to embargoed requests" do
      embargoed = FactoryGirl.create(:embargoed_request)
      incoming = FactoryGirl.create(:incoming_message,
                                    :info_request => embargoed)
      attachment = FactoryGirl.create(:html_attachment,
                                      :incoming_message => incoming)

      exportable = described_class.exportable_foi_attachments(cut_off)
      expect(exportable).to_not include(attachment)
    end

  end

end
