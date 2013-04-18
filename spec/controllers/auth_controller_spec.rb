require 'spec_helper'

describe AuthController do

  describe "GET 'login'" do
    it "returns http success" do
      get 'login'
      response.should be_redirect
    end
  end

  describe "GET 'logout'" do
    it "returns http success" do
      get 'logout'
      response.should be_redirect
    end
  end

end
