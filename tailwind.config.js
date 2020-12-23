module.exports = {
  future: {
    purgeLayersByDefault: true,
  },
  purge: {
    enabled: ((process.env.BUILD_ENV === 'prod') ? true : false),
    content: [
      './_site/*.html',
      './_site/**/*.html',
    ],
  },
  theme: {
    extend: {
      colors: {
        'sea-blue': {
          100: '#E7F3F6',
          200: '#C3E1E7',
          300: '#9FCFD9',
          400: '#58ACBD',
          500: '#1088A0',
          600: '#0E7A90',
          700: '#0A5260',
          800: '#073D48',
          900: '#052930',
        },
        'sand-yellow': {
          100: '#FEFBF8',
          200: '#FDF6EC',
          300: '#FCF0E1',
          400: '#FAE5CB',
          500: '#F8DAB4',
          600: '#DFC4A2',
          700: '#95836C',
          800: '#706251',
          900: '#4A4136',
        },
        'elixir': {
          default: '#9E7BEA',
          '100': '#F9F6FE',
          '200': '#E2D7F9',
          '300': '#CBB8F4',
          '400': '#B59AEF',
          '500': '#9E7BEA',
          '600': '#6A34DF',
          '700': '#471AA8',
          '800': '#290F61',
          '900': '#0B041A'
        },
      },
    },
  },
  variants: {},
  plugins: [
    require('@tailwindcss/typography'),
  ],
}
