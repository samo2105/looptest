/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Design tokens from screenshot
        'bg-dark': '#2a2a2a', // Dark grey background
        'bg-light': '#f5f5f5', // Light grey content area
        'logo-red': '#e63946', // Red for loopstudio logo
        'text-primary': '#1a1a1a', // Black/dark grey for primary text
        'text-secondary': '#6b6b6b', // Lighter grey for secondary text
        'border-grey': '#d1d1d1', // Grey for borders and separators
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        'card': '8px', // Rounded corners for content card
        'input': '4px', // Rounded corners for inputs
      },
      boxShadow: {
        'card': '0 2px 8px rgba(0, 0, 0, 0.1)', // Subtle shadow for content card
      },
    },
  },
  plugins: [],
}

