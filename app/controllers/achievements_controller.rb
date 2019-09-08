class AchievementsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :owners_only, only: [:edit, :update, :destroy]
  def index
    @achievements = Achievement.public_access
  end

  def edit; end

  def update
    if @achievement.update_attributes(achievement_params)
      redirect_to @achievement
    else
      render 'edit'
    end
  end

  def new
    @achievement = current_user.achievements.new
  end

  def create
    @achievement = current_user.achievements.new(achievement_params)
    if @achievement.save
      UserMailer.achievement_created(current_user.email, @achievement.id).deliver_now
      redirect_to achievement_path(@achievement), notice: "Achievement has been created"
    else
      render :new
    end
  end

  def show
    @achievement = Achievement.find params[:id]
  end

  def destroy
    @achievement.destroy
    redirect_to achievements_path
  end

  private

  def achievement_params
    params.require(:achievement).permit(:title, :description, :privacy, :cover_image, :featured)
  end

  def owners_only
    @achievement = current_user.achievements.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # if current_user != @achievement.user
    #   redirect_to achievements_path
    # end
    redirect_to achievements_path
  end
end
