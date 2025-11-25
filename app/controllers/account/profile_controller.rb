class Account::ProfileController < Account::BaseController
  def show
    @user = current_user
    render template: "account/profile/show"
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to account_profile_path, notice: "Profile updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :profile_picture)
  end
end
