// Seller registration controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for seller_registration_controller');
    return;
  }
  
  application.register('seller-registration', class extends window.Stimulus.Controller {
    static targets = ["step", "nextButton", "prevButton", "progress", "progressText"];
    
    connect() {
      console.log("Seller registration controller connected");
      this.currentStep = 0;
      this.totalSteps = this.stepTargets.length;
      this.updateUI();
    }
    
    next() {
      // Validate current step if needed
      if (!this.validateCurrentStep()) {
        return;
      }
      
      // Move to next step if not on last step
      if (this.currentStep < this.totalSteps - 1) {
        this.currentStep++;
        this.updateUI();
      }
    }
    
    prev() {
      // Move to previous step if not on first step
      if (this.currentStep > 0) {
        this.currentStep--;
        this.updateUI();
      }
    }
    
    updateUI() {
      // Hide all steps
      this.stepTargets.forEach((step, index) => {
        if (index === this.currentStep) {
          step.classList.remove('hidden');
        } else {
          step.classList.add('hidden');
        }
      });
      
      // Update buttons
      if (this.hasPrevButtonTarget) {
        this.prevButtonTarget.disabled = this.currentStep === 0;
      }
      
      if (this.hasNextButtonTarget) {
        if (this.currentStep === this.totalSteps - 1) {
          this.nextButtonTarget.textContent = 'Submit';
        } else {
          this.nextButtonTarget.textContent = 'Next';
        }
      }
      
      // Update progress
      if (this.hasProgressTarget) {
        const progressPercent = (this.currentStep / (this.totalSteps - 1)) * 100;
        this.progressTarget.style.width = `${progressPercent}%`;
      }
      
      if (this.hasProgressTextTarget) {
        this.progressTextTarget.textContent = `Step ${this.currentStep + 1} of ${this.totalSteps}`;
      }
    }
    
    validateCurrentStep() {
      const currentStepElement = this.stepTargets[this.currentStep];
      const requiredFields = currentStepElement.querySelectorAll('[required]');
      
      let isValid = true;
      
      requiredFields.forEach(field => {
        if (!field.value) {
          isValid = false;
          field.classList.add('border-red-500');
        } else {
          field.classList.remove('border-red-500');
        }
      });
      
      return isValid;
    }
  });
})();
