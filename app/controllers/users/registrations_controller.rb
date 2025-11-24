module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [ :create ]
    before_action :configure_account_update_params, only: [ :update ]

    # GET /resource/sign_up
    def new
      # Set @become_seller based on query param to prefill the checkbox
      @become_seller = params[:seller] == "true"
      super
    end

    # POST /resource
    def create
      super do |user|
        # Check if user wants to become a seller
        if params[:become_seller] == "1" && user.persisted?
          # Create a seller profile
          seller = Seller.new(
            user: user,
            business_name: "#{user.first_name}'s Store",
            commission_rate: 10.0 # Default commission rate
          )

          if seller.save
            # Log the creation of seller account
            UserActivity.create(
              user: user,
              activity_type: "seller_registration",
              title: "Registered as a seller",
              description: "Created seller account with business name: #{seller.business_name}",
              icon: "store",
              color: "purple"
            )
          end
        end
      end
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    def update
      # Check for profile picture upload
      if params[:user] && params[:user][:profile_picture].present?
        # Process the profile picture before update
        begin
          # ActiveStorage will handle this automatically when the update happens
          # This is just a placeholder for additional logic if needed
        rescue => e
          flash[:alert] = "There was an error processing your profile picture: #{e.message}"
          redirect_to edit_user_registration_path and return
        end
      end

      super do |user|
        # Create a seller profile if user wants to become a seller and doesn't already have one
        if params[:become_seller] == "1" && !user.seller.present? && user.errors.empty?
          seller = Seller.new(
            user: user,
            business_name: params[:business_name].presence || "#{user.first_name}'s Store",
            commission_rate: 10.0 # Default commission rate
          )

          if seller.save
            # Log the creation of seller account
            UserActivity.create(
              user: user,
              activity_type: "seller_registration",
              title: "Registered as a seller",
              description: "Created seller account with business name: #{seller.business_name}",
              icon: "store",
              color: "purple"
            )
          end
        end
      end
    end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :profile_picture ])
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :profile_picture ])
    end

    # The path used after sign up.
    def after_sign_up_path_for(resource)
      if resource.seller.present?
        # Redirect to seller dashboard when implemented
        root_path
      else
        super(resource)
      end
    end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
