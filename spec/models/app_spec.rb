require 'rails_helper'

RSpec.describe App, type: :model do
  it{ should have_many(:users).through(:app_users) }
  it{ should have_many(:conversations) }
  it{ should have_many(:segments) }

  let(:app){
    FactoryGirl.create :app
  }

  it "create app" do
    expect(app).to be_valid
    expect(app.key).to be_present
  end

  it "create an user" do 
    app.add_user({email: "test@test.cl", first_name: "dsdsa"})
    expect(app.users).to be_any   
    expect(app.app_users.first.first_name).to be_present  
  end

  describe "existing user" do 

    before do 
      app.add_user({email: "test@test.cl", first_name: "dsdsa"})
    end

    it "add existing user will keep count but update properties" do 
      app.add_user({email: "test@test.cl", first_name: "edited name"})
      expect(app.reload.users.size).to be == 1
      expect(app.reload.app_users.first.first_name).to be == "edited name"
    end

    it "add other user will increase count of app_users" do 
      app.add_user({email: "test@test2.cl", first_name: "edited name"})
      expect(app.reload.users.size).to be == 2
      expect(app.reload.app_users.last.first_name).to be == "edited name"
    end

    it "add visit on new user" do
      app.add_visit({email: "foo@bar.org", properties: {browser: "chrome"}})
      expect(app.app_users.size).to be == 2
    end

    it "add visit on existing user" do
      app.add_visit({email: "test@test.cl", properties: {browser: "chrome"}})
      expect(app.app_users.size).to be == 1
      expect(app.app_users.first.properties["browser"]).to be == "chrome"
    end

    describe "other app" do 
      before do 
        @app2 = FactoryGirl.create :app
      end

      it "will update attrs for user on app2 only" do
        @app2.add_user({email: "test@test.cl", properties: {first_name: "edited for app 2"}})
        expect(@app2.users.count).to be == 1
        expect(@app2.app_users.last.first_name).to be == "edited for app 2"
        expect(app.app_users.first.first_name).to be == "dsdsa"
        expect(app.users.first.email).to be == @app2.users.first.email
      end
    end
  end

  it "create_conversation" do
    app_user = app.add_user({email: "test@test.cl", first_name: "dsdsa"})
    conversations = app.start_conversation({
      message: "message", 
      from: app_user.user
    })
    expect(app.conversations.count).to be == 1
  end

end