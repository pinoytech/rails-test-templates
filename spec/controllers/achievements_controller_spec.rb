require 'rails_helper'

describe AchievementsController do

  shared_examples "public access to achievements" do

    describe "GET index" do
      it "renders :index template" do
        get :index 
        expect(response).to render_template(:index)
      end
  
      it "assigns only public achievements to template" do
        public_achievement = FactoryGirl.create(:public_achievement)
        private_achievement = FactoryGirl.create(:private_achievement)
        get :index
        expect(assigns(:achievements)).to match_array([public_achievement])
      end
    end

    describe "GET show" do
      let(:achievement) { FactoryGirl.create(:public_achievement) }
      it "renders :show template" do
        get :show, params: { id: achievement.id }
        expect(response).to render_template(:show)
      end
      it "assigns requested achievement to @achievement" do
        get :show, params: { id: achievement }
        expect(assigns(:achievement)).to eq(achievement) 
      end
    end
  end

  describe "guest user" do

    it_behaves_like "public access to achievements"

    describe "GET new" do
      it "redirects to new user login" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST create" do
      let(:achievement) { FactoryGirl.attributes_for(:public_achievement) }
      it "redirects to user login" do
        post :create, params: { achievement: achievement }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET edit" do
      let(:achievement) { FactoryGirl.create(:public_achievement) }
      it "redirects to user login" do
        get :edit, params: { id: achievement }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "PUT create" do
      let(:achievement) { FactoryGirl.create(:public_achievement)}
      let(:valid_data) { FactoryGirl.attributes_for(:public_achievement, title: "Nice one") }
      it "redirects to user login" do
        put :update, params: { id: achievement.id, achievement: valid_data }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "DELETE destroy" do
      let(:achievement) { FactoryGirl.create(:public_achievement) }
      it "redirects to user login" do
        delete :destroy, params: { id: achievement.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "authenticated user" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in(user)
    end

    it_behaves_like "public access to achievements"

    describe "GET new" do
      it "renders new template" do
        get :new
        expect(response).to render_template(:new)
      end
  
      it "assigns new Achievement to @achievement" do
        get :new
        # assigns = all instance variables
        expect(assigns(:achievement)).to be_a_new(Achievement)
      end
    end

    describe "POST create" do
      let(:valid_data) { FactoryGirl.attributes_for(:public_achievement, user: user) }
  
      context "valid data" do
        it "redirects to show page" do
          post :create, params: { achievement: valid_data }
          expect(response).to redirect_to(achievement_path(assigns[:achievement]))
        end
  
        it "creates new achievement in database" do
          expect{
            post :create, params: { achievement: valid_data }
          }.to change(Achievement, :count).by(1)
        end
  
      end
  
      # context "invalid data" do
      #   it "renders :new template" do
      #     post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement, title: '') }
      #     expect(response).to render_template(:new)
      #   end
      #   it "doesn't create new achievement" do
      #     expect{
      #       post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement, title: '') }
      #     }.not_to change(Achievement, :count)
      #   end
      # end
  
      context "invalid data" do
        let(:invalid_data) { FactoryGirl.attributes_for(:public_achievement, title: '') }
  
        it "renders :new template" do
          post :create, params: { achievement: invalid_data }
          expect(response).to render_template(:new)
        end
  
        it "doesn't create new achievement" do
          expect{
            post :create, params: { achievement: invalid_data }
          }.not_to change(Achievement, :count)
        end
  
      end
    end

    context "is not the owner of the achievement" do
      let(:another_user) { FactoryGirl.create(:user) }
      let(:achievement) { FactoryGirl.create(:public_achievement, user: another_user) }

      describe "GET edit" do
        it "redirects to user login" do
          get :edit, params: { id: achievement }
          expect(response).to redirect_to(achievements_path)
        end
      end
  
      describe "PUT create" do
        let(:valid_data) { FactoryGirl.attributes_for(:public_achievement, title: "Nice one") }
        it "redirects to user login" do
          put :update, params: { id: achievement.id, achievement: valid_data }
          expect(response).to redirect_to(achievements_path)
        end
      end
  
      describe "DELETE destroy" do
        it "redirects to user login" do
          delete :destroy, params: { id: achievement.id }
          expect(response).to redirect_to(achievements_path)
        end
      end
    end

    context "is the owner of the achievement" do
      let(:achievement) { FactoryGirl.create(:achievement, user: user) }

      describe "GET edit" do
        it "renders :edit template" do
          get :edit, params: { id: achievement.id }
          expect(response).to render_template(:edit)
        end

        it "assigns the requested achievement to template" do
          get :edit, params: { id: achievement.id }
          expect(assigns(:achievement)).to eq(achievement)
        end
      end

      describe "PUT update" do
        context "valid data" do
          let(:valid_data) { FactoryGirl.attributes_for(:public_achievement, title: "New title") }

          it "redirects to achievements#show" do
            put :update, params: { id: achievement, achievement: valid_data }
            expect(response).to redirect_to(achievement)
          end

          it "updates achievement in the database" do
            put :update, params: { id: achievement, achievement: valid_data }
            achievement.reload #something happened to the variable. reload it to get the updated values
            expect(achievement.title).to eq("New title")
          end
        end

        context "invalid data" do
          let(:invalid_data) { FactoryGirl.attributes_for(:public_achievement, title: "", description: 'new description') }

          it "renders :edit template" do
            put :update, params: { id: achievement, achievement: invalid_data }
            expect(response).to render_template(:edit)
          end

          it "doesn't update achievement in the database" do
            put :update, params: { id: achievement, achievement: invalid_data }
            achievement.reload #something happened to the variable. reload it to get the updated values
            expect(achievement.description).to_not eq("new")
          end

        end
      end

      describe "DELETE destroy" do
        it "redirects to index page" do
          delete :destroy, params: { id: achievement.id }
          expect(response).to redirect_to(achievements_path)
        end

        # it "deletes achievement from the database" do
        #   expect {
        #     delete :destroy, params: { id: achievement.id }
        #   }.to change(Achievement, :count).by(0)
        # end
        it "deletes achievement from the database" do
          delete :destroy, params: { id: achievement.id }
          expect(Achievement.exists?(achievement.id)).to be_falsy
        end

      end
    end
  end
end