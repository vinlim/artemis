/** @type {import('tailwindcss').Config} */
const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config} */
module.exports = {
    purge: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
    darkMode: 'class',
    content: ["build/**/*.{html,js}"],
    theme: {
        extend: {
            colors: {
                'primary': '#40C381',
                'primary-dark': '#1C633F',
                'primary-light': '#D7EAE0',
                'primary-lighter': '#E5F1EA',
                'primary-accent': '#B7ECD1',
                'secondary': '#111F2C',
                'secondary-lighter': '#213140',
                'secondary-darker': '#0D151D',
                'tertiary': '#F0B356',
                'accent-gray': '#818C86',
                'dark-red': "#A94442",
                'danger': '#CF3310',
            },
            fontFamily: {
                sans: ['Poppins', defaultTheme.fontFamily.sans],
                mono: ['IBM Plex Mono', defaultTheme.fontFamily.mono],
                poppins: ["Poppins", defaultTheme.fontFamily.sans],
                mont: ["Montserrat", defaultTheme.fontFamily.sans],
            },
        },
    },
    plugins: [],
}

