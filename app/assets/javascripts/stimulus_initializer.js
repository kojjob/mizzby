// Initialize Stimulus for legacy asset pipeline
document.addEventListener('DOMContentLoaded', function() {
  // Create Stimulus application if it doesn't exist
  if (!window.Stimulus) {
    console.log('Creating legacy Stimulus application for asset pipeline compatibility');
    
    // Create a minimal Stimulus-like API for our controllers
    window.Stimulus = {
      application: {
        controllers: {},
        register: function(identifier, controllerClass) {
          this.controllers[identifier] = controllerClass;
          console.log(`Registered controller: ${identifier}`);
          
          // Find all elements with this controller
          document.querySelectorAll(`[data-controller~="${identifier}"]`).forEach(element => {
            // Initialize the controller
            this.initializeController(element, identifier);
          });
        },
        initializeController: function(element, identifier) {
          const ControllerClass = this.controllers[identifier];
          if (!ControllerClass) return;
          
          // Create controller instance
          const controller = new ControllerClass();
          
          // Set properties
          controller.element = element;
          controller.identifier = identifier;
          
          // Find targets
          if (ControllerClass.targets) {
            ControllerClass.targets.forEach(targetName => {
              const targetsKey = `${targetName}Targets`;
              const hasTargetKey = `has${targetName.charAt(0).toUpperCase() + targetName.slice(1)}Target`;
              
              // Find elements with data-{identifier}-target={targetName}
              const targetElements = element.querySelectorAll(`[data-${identifier}-target="${targetName}"]`);
              
              // Set targets property
              controller[targetsKey] = Array.from(targetElements);
              controller[hasTargetKey] = targetElements.length > 0;
              
              // Set individual target if exists
              if (targetElements.length > 0) {
                controller[`${targetName}Target`] = targetElements[0];
              }
            });
          }
          
          // Connect the controller
          if (typeof controller.connect === 'function') {
            controller.connect();
          }
          
          // Set up actions
          const actions = [];
          element.getAttributeNames().forEach(attr => {
            if (attr.startsWith('data-action') && attr.includes(`${identifier}#`)) {
              const actionValue = element.getAttribute(attr);
              actionValue.split(' ').forEach(action => {
                if (action.includes(`${identifier}#`)) {
                  const [eventName, controllerAction] = action.split('->');
                  if (controllerAction) {
                    const [controllerName, methodName] = controllerAction.split('#');
                    if (controllerName === identifier) {
                      actions.push({event: eventName, method: methodName});
                    }
                  }
                }
              });
            }
          });
          
          // Add event listeners for actions
          actions.forEach(action => {
            element.addEventListener(action.event, (event) => {
              if (typeof controller[action.method] === 'function') {
                controller[action.method](event);
              }
            });
          });
          
          // Store controller reference on element
          element.__controller = controller;
        }
      }
    };
  }
  
  // Initialize any controllers that were loaded
  console.log('Stimulus initialization complete');
});
