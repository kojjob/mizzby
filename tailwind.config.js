/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.{erb,html,html.erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/components/**/*.{rb,html.erb}'
  ],
  theme: {
    extend: {
      animation: {
        'fade-in-down': 'fadeInDown 0.2s ease-out',
        'fade-out-up': 'fadeOutUp 0.2s ease-in',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'bounce-horizontal': 'bounceHorizontal 1s infinite',
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
        bounceHorizontal: {
          '0%, 100%': {
            transform: 'translateX(-25%)',
            animationTimingFunction: 'cubic-bezier(0.8, 0, 1, 1)'
          },
          '50%': {
            transform: 'translateX(25%)',
            animationTimingFunction: 'cubic-bezier(0, 0, 0.2, 1)'
          },
        },
      },
      transitionProperty: {
        'max-height': 'max-height',
      },
    },
  },
  plugins: [
    function({ addUtilities }) {
      const newUtilities = {
        '.animate-once': {
          'animation-iteration-count': '1',
        },
      }
      addUtilities(newUtilities)
    },
  ],
}
