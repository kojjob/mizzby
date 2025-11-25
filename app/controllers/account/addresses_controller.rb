class Account::AddressesController < Account::BaseController
  before_action :set_address, only: [:show, :edit, :update, :destroy]

  def index
    @addresses = current_user.addresses.order(default: :desc, created_at: :desc)
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)
    
    if @address.save
      redirect_to account_addresses_path, notice: "Address added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to account_addresses_path, notice: "Address updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to account_addresses_path, notice: "Address removed successfully."
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:name, :street_address, :street_address_2, :city, :state, :postal_code, :country, :phone, :default)
  end
end
