const colors = require('tailwindcss/colors')

module.exports = {
  purge: [
    './js/**/*.js',
    '../lib/plausible_web/templates/**/*.html.eex',
  ],
  darkMode: 'class',
  theme: {
    container: {
      center: true,
      padding: '1rem',
    },
    extend: {
      colors: {
        orange: colors.orange,
        'gray-850': 'rgb(26, 32, 44)',
        'gray-825': 'rgb(37, 47, 63)'
      },
      spacing: {
        '44': '11rem'
      },
      width: {
        '31percent': '31%',
      },
      opacity: {
        '15': '0.15',
      }
    },
  },
  variants: {
    textColor: ['responsive', 'hover', 'focus', 'group-hover'],
    display: ['responsive', 'hover', 'focus', 'group-hover'],
    extend: {
      textColor: ['dark'],
      borderWidth: ['dark'],
      backgroundOpacity: ['dark']
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ]
}
