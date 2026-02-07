/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        void: {
          DEFAULT: '#08080C',
          50: '#0A0A10',
          100: '#0D0D14',
          200: '#101018',
          300: '#13131A',
          400: '#15151E',
          500: '#1C1C27',
          600: '#252533',
          700: '#2E2E40',
          800: '#3A3A4D',
        },
        violet: {
          DEFAULT: '#8B5CF6',
          50: '#F3EFFE',
          100: '#E0D4FC',
          200: '#C4A8F9',
          300: '#A87CF6',
          400: '#8B5CF6',
          500: '#7C3AED',
          600: '#6D28D9',
          700: '#5B21B6',
          800: '#4C1D95',
        },
        ash: {
          DEFAULT: '#6B6B80',
          50: '#EBEBEF',
          100: '#CDCDD6',
          200: '#A8A8B8',
          300: '#83839A',
          400: '#6B6B80',
          500: '#525266',
          600: '#3E3E4D',
          700: '#2A2A35',
        },
      },
      fontFamily: {
        display: ['"Instrument Serif"', 'Georgia', 'serif'],
        body: ['"DM Sans"', 'system-ui', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'float-delayed': 'float 6s ease-in-out 2s infinite',
        'pulse-violet': 'pulse-violet 4s ease-in-out infinite',
        'shimmer': 'shimmer 3s ease-in-out infinite',
        'glow': 'glow 2s ease-in-out infinite alternate',
        'grain': 'grain 8s steps(10) infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-16px)' },
        },
        'pulse-violet': {
          '0%, 100%': { opacity: '0.4' },
          '50%': { opacity: '0.8' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
        glow: {
          '0%': { boxShadow: '0 0 20px rgba(139, 92, 246, 0.15)' },
          '100%': { boxShadow: '0 0 60px rgba(139, 92, 246, 0.3)' },
        },
        grain: {
          '0%, 100%': { transform: 'translate(0, 0)' },
          '10%': { transform: 'translate(-5%, -10%)' },
          '20%': { transform: 'translate(-15%, 5%)' },
          '30%': { transform: 'translate(7%, -25%)' },
          '40%': { transform: 'translate(-5%, 25%)' },
          '50%': { transform: 'translate(-15%, 10%)' },
          '60%': { transform: 'translate(15%, 0%)' },
          '70%': { transform: 'translate(0%, 15%)' },
          '80%': { transform: 'translate(3%, 35%)' },
          '90%': { transform: 'translate(-10%, 10%)' },
        },
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic': 'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
      },
    },
  },
  plugins: [],
}
