module.exports = {
  // Your existing config...
  theme: {
    extend: {
      // Your existing extensions...
      
      animation: {
        'fade-in-down': 'fadeInDown 0.2s ease-out',
        'fade-out-up': 'fadeOutUp 0.2s ease-in',
      },
      keyframes: {
        fadeInDown: {
          '0%': {
            opacity: '0',
            transform: 'translateY(-0.5rem)'
          },
          '100%': {
            opacity: '1',
            transform: 'translateY(0)'
          },
        },
        fadeOutUp: {
          '0%': {
            opacity: '1',
            transform: 'translateY(0)'
          },
          '100%': {
            opacity: '0',
            transform: 'translateY(-0.5rem)'
          },
        },
      },
      transitionProperty: {
        'max-height': 'max-height',
      },
    },
  },
  // The rest of your config...
}