import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        binary: {
          50:  "#F2F6FC",
          100: "#D9E1F2",
          500: "#2C5582",
          600: "#234668",
          700: "#1F3A68",
          900: "#102040"
        }
      }
    }
  },
  plugins: []
};
export default config;
