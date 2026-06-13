/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['"Plus Jakarta Sans"', 'Inter', 'system-ui', 'sans-serif'],
        urdu: ['"Noto Nastaliq Urdu"', 'serif'],
      },
      letterSpacing: {
        tightest: '-0.04em',
      },
      colors: {
        primary: '#0d5c2e',
        'primary-light': '#15803d',
        'primary-pale': '#ecfdf3',
        brandBlue: 'var(--color-blue)',
        'brand-blue-mid': 'var(--color-blue-mid)',
        'brand-blue-light': 'var(--color-blue-light)',
        gold: 'var(--color-gold)',
        'gold-light': 'var(--color-gold-light)',
        dark: 'var(--color-dark)',
        grey: 'var(--color-grey)',
        'grey-light': 'var(--color-grey-light)',
      },
    },
  },
  plugins: [],
};
