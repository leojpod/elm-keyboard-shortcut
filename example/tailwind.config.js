module.exports = {
  content: [
    './src/elm/**/*.elm',
    './src/typescript/**/*.ts',
    'index.*',
    'css/style.css'
  ],
  theme: {
    extend: {
      animation: {
        'fade-out': 'fade-out 1s ease-out 1 forwards'
      },
      keyframes: {
        'fade-out': {
          '0%': { opacity: 1 },
          '100%': { opacity: 0 }
        }
      }
    }
  },
  safelist: process.env.SAFELISTING ? [{ pattern: /.*/ }] : [],
  variants: {},
  plugins: []
}
