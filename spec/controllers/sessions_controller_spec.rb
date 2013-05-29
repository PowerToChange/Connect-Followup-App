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
        response.should redirect_to(surveys_path)
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
    it 'redirects to my connections page' do
      subject
      response.should redirect_to(surveys_path)
    end
  end
end
