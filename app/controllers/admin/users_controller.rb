module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :toggle_admin, :impersonate ]
    before_action -> { authorize_action(:manage_users) }
    before_action -> { authorize_action(:delete_users) }, only: [ :destroy ]
    before_action -> { authorize_action(:create_users) }, only: [ :new, :create ]
    before_action :authorize_super_admin, only: [ :toggle_admin, :impersonate ]

    def index
      @users = User.includes(:seller)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(25)

      # Filter by role if provided
      if params[:role].present?
        case params[:role]
        when "admin"
          @users = @users.where(admin: true)
        when "super_admin"
          @users = @users.where(super_admin: true)
        when "seller"
          @users = @users.joins(:seller)
        end
      end

      # Search by name or email if provided
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @users = @users.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
                             search_term, search_term, search_term)
      end

      # Status filter
      if params[:status].present?
        @users = @users.where(active: params[:status] == "active")
      end
    end

    def show
      # Load user's orders
      @orders = @user.orders.order(created_at: :desc).limit(10)

      # Load user's products if they're a seller
      @products = @user.seller&.products&.order(created_at: :desc)&.limit(10) || []

      # Load activity logs
      @activities = @user.user_activities.order(created_at: :desc).limit(15)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      # Generate a random password if not provided
      if params[:generate_password] && @user.password.blank?
        generated_password = SecureRandom.hex(8)
        @user.password = generated_password
        @user.password_confirmation = generated_password
      end

      if @user.save
        # If this is a seller account, create the seller profile
        if params[:user][:seller] == "1"
          @user.create_seller(business_name: "#{@user.full_name}'s Store")
        end

        flash[:success] = "User was successfully created."
        if params[:generate_password]
          flash[:info] = "Generated password: #{generated_password}"
        end
        redirect_to admin_user_path(@user)
      else
        flash.now[:error] = "There was a problem creating the user."
        render :new
      end
    end

    def edit
    end

    def update
      # Only super_admins can change admin status
      if !current_user.super_admin? && user_params[:admin].present?
        flash[:error] = "Only super admins can change admin status."
        return redirect_to admin_user_path(@user)
      end

      # Users can't remove their own admin status
      if current_user == @user && user_params[:admin] == "0" && @user.admin?
        flash[:error] = "You cannot remove your own admin privileges."
        return redirect_to admin_user_path(@user)
      end

      if @user.update(user_params)
        flash[:success] = "User was successfully updated."
        redirect_to admin_user_path(@user)
      else
        flash.now[:error] = "There was a problem updating the user."
        render :edit
      end
    end

    def destroy
      # Don't allow deleting yourself
      if current_user == @user
        flash[:error] = "You cannot delete your own account."
        return redirect_to admin_users_path
      end

      # Don't allow deleting super admins unless you're a super admin
      if @user.super_admin? && !current_user.super_admin?
        flash[:error] = "Only super admins can delete super admin accounts."
        return redirect_to admin_users_path
      end

      if @user.destroy
        flash[:success] = "User was successfully deleted."
      else
        flash[:error] = "User could not be deleted: #{@user.errors.full_messages.join(', ')}"
      end

      redirect_to admin_users_path
    end

    def toggle_admin
      # Don't allow removing your own admin privileges
      if current_user == @user
        flash[:error] = "You cannot change your own admin status."
        return redirect_to admin_user_path(@user)
      end

      if @user.update(admin: !@user.admin)
        new_status = @user.admin? ? "granted" : "revoked"
        flash[:success] = "Admin privileges #{new_status} for #{@user.full_name}."
      else
        flash[:error] = "Could not update admin status."
      end

      redirect_to admin_user_path(@user)
    end

    def impersonate
      # Store the current admin's ID in the session
      session[:admin_id] = current_user.id

      # Sign in as the target user
      sign_in(@user, bypass: true)

      flash[:success] = "You are now impersonating #{@user.full_name}. Sign out to return to your account."
      redirect_to root_path
    end

    def stop_impersonating
      # Ensure there's an admin to return to
      if session[:admin_id].present?
        admin = User.find_by(id: session[:admin_id])

        if admin
          # Sign in as the original admin
          sign_in(admin, bypass: true)
          flash[:success] = "You are no longer impersonating another user."
        else
          flash[:error] = "Could not return to admin account."
        end

        # Clear the stored admin ID
        session.delete(:admin_id)
      end

      redirect_to admin_root_path
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted_params = [ :first_name, :last_name, :email, :password, :password_confirmation, :active ]

      # Allow admin/super_admin params only for super_admins
      if current_user.super_admin?
        permitted_params += [ :admin, :super_admin ]
      end

      params.require(:user).permit(permitted_params)
    end
  end
end
