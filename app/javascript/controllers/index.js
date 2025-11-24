import { application } from "controllers/application"

// Import controllers
import DropdownController from "./dropdown_controller"
import MobileMenuController from "./mobile_menu_controller"
import FlashMsgController from "./flash_msg_controller"
import CartModalController from "./cart_modal_controller"
import CartDropdownController from "./cart_dropdown_controller"
import ProfilePictureController from "./profile_picture_controller"
import SellerRegistrationController from "./seller_registration_controller"
import TabController from "./tab_controller"

// Register controllers
application.register("dropdown", DropdownController)
application.register("mobile-menu", MobileMenuController)
application.register("flash-msg", FlashMsgController)
application.register("cart-modal", CartModalController)
application.register("cart-dropdown", CartDropdownController) 
application.register("profile-picture", ProfilePictureController)
application.register("seller-registration", SellerRegistrationController)
application.register("tab", TabController)

// Optionally import all controllers from `controllers` directory
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

console.log("Stimulus controllers registered successfully")
