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
    context 'when logged into CAS but not in local Connect app' do
      before do
        ApplicationController.any_instance.stub(:cas_logged_in?) { 'adrian@ballistiq.com' }
        ApplicationController.any_instance.stub(:current_user) { nil }
      end
      it 'shows flash alert message of user not found' do
        subject
        flash[:alert].should_not be_empty
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

    context 'when return from success CAS authentication' do
      before do
        User.any_instance.stub(:sync_schools_from_pulse).and_return(true)
      end

      it 'redirects to my connections page' do
        subject
        response.should redirect_to(connections_path)
      end

      it 'updates current_user attributes from cas session' do
        User.any_instance.should_receive(:update_attributes)
        subject
      end

      it 'syncs current_user schools from the Pulse' do
        User.any_instance.should_receive(:sync_schools_from_pulse)
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
  end
end
