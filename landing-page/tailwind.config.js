/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#3366E6',
        'primary-light': '#4D80F2',
        'primary-dark': '#264DCC',
        accent: '#E64D80',
        background: '#1a1a2e',
        'background-light': '#16213e',
        surface: '#0f3460',
        'text-primary': '#ffffff',
        'text-secondary': '#a0aec0',
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'sans-serif'],
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'pulse-glow': 'pulse-glow 2s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-20px)' },
        },
        'pulse-glow': {
          '0%, 100%': { boxShadow: '0 0 20px rgba(51, 102, 230, 0.3)' },
          '50%': { boxShadow: '0 0 40px rgba(51, 102, 230, 0.6)' },
        },
      },
    },
  },
  plugins: [],
}
