require 'spec_helper'

describe SessionsController do

  describe 'GET /sessions/new' do
    subject { get :new }

    context 'when not logged in' do
      it { should be_success }
    end

    context 'when logged in' do
      login_user
      it 'redirects to my connections page' do
        subject
        response.should redirect_to(connections_path)
      end
    end

    context 'when logging into app for the first time' do
      before do
        ApplicationController.any_instance.stub(:cas_logged_in?) { 'adrian@ballistiq.com' }
        session[:cas_extra_attributes] = { ssoGuid: 'myfancyguid' }
      end

      it 'creates new user if not found' do
        User.where(guid: 'myfancyguid').first.should_not be_present
        subject
        User.where(guid: 'myfancyguid').first.should be_present
      end
    end
  end

  describe 'GET /sessions/destroy' do
    subject { delete :destroy }
    before do
      session[:cas_user] = 'adrian@ballistiq.com'
    end
    it 'logs out user' do
      subject
      controller.send(:current_user).should be_nil
    end
    it 'redirects back to login page' do
      subject
      response.should be_redirect
    end
  end

  describe 'GET /sessions' do
    login_user
    subject { get :index }

    before do
      User.any_instance.stub(:sync_schools_from_pulse).and_return(true)
    end

    context 'when return from success CAS authentication' do

      it 'redirects to my connections page' do
        subject
        response.should redirect_to(connections_path)
      end

      it 'calls after_login' do
        SessionsController.any_instance.should_receive(:after_login)
        subject
      end

      context 'but without an existing user account in Connect' do
        before do
          ApplicationController.any_instance.stub(:current_user) { nil }
        end

        it 'redirects back to login page' do
          subject
          response.should redirect_to(log_in_path)
        end
      end
    end

    context 'after login' do
      it 'updates current user attributes' do
        User.any_instance.should_receive(:update_attributes)
        subject
      end

      it 'syncs current user schools from Pulse' do
        User.any_instance.should_receive(:sync_schools_from_pulse)
        subject
      end
    end
  end
end
