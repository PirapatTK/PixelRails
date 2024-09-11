class UsersController < ApplicationController
  before_action :set_categories
  before_action :set_selected_category, only: [:index]
  before_action :set_search, only: [:index]

  def set_categories
    @catagories = ['All','Math', 'Science', 'History', 'English']
  end

  def set_selected_category
    @selected_category = params[:category] || "All"
  end

  def set_search
    @search = params[:search] || ""
  end

  def index
    @users = User.all
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @users = User.all
    @selected_category = "All"
    
    if @user.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('user_form', partial: 'users/form', locals: { user: User.new }),
            if @users.length == 1
              turbo_stream.replace('users_list_div', partial: 'users/users_list', locals: { users: @users })
            else 
              # turbo_stream.prepend('users_lists', partial: 'users/user', locals: { user: @user })
              turbo_stream.replace('users_list_div', partial: 'users/users_list', locals: { users: @users })
            end,
          ]
        end
      end
    else
      render :index
    end
  end
  

  def edit
    @users = User.all
    @user = User.find(params[:id])

    if @user == nil
      redirect_to users_path
    end
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('user_form', partial: 'users/form', locals: { user: @user })
      end
      format.html { render :edit }
    end
  end

  def update
    @user = User.find(params[:id])
    @users = User.all
    @selected_category = "All"
    
    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('user_form', partial: 'users/form', locals: { user: User.new }),
            turbo_stream.replace('users_list_div', partial: 'users/users_list', locals: { users: @users }),
          ]
        end
      end
    else
      render :index
    end
  end
  
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    @users = User.all
  
    respond_to do |format|
      format.turbo_stream do
        if @users.any?
          render turbo_stream: turbo_stream.remove(@user)
        else
          render turbo_stream: turbo_stream.remove('users_list_box')
        end
      end
      format.html { redirect_to users_path, notice: 'User was successfully destroyed.' }
    end
  end
  


  def user_params
    params.require(:user).permit(:first_name, :last_name, :birth_date, :gender, :email, :phone_number, :subject)
  end
end
