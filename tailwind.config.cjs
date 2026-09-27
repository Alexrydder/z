const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.{js,ts,vue}",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        "umn-maroon": "#1a5f2a",
        "umn-maroon-dark": "#0f3d1a",
        "umn-gold": "#a67c2b",
        "umn-gold-light": "#c69a3e",
        "umn-neutral-50": "#faf7f0", // page background color
        "umn-neutral-100": `#e8e2d1`, // gray for navbar
        "umn-neutral-200": `#d5d6d2`,
        "umn-neutral-500": `#737487`,
        "umn-neutral-700": `#5b5548`, // text color
        "umn-neutral-800": `#262626`, // active text color
        "umn-neutral-900": `#1a1a1a`,
        "twitter-blue": "#51adec",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
  ],

  // add prefix to avoid conflicts with legacy css
  prefix: "tw-",
  corePlugins: {
    // preflight: false,
  },
};
