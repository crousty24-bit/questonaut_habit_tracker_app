# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.

# Asset cache version number.
# Changing this value forces the browser to reload all assets (cache-busting).
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Adds app/assets/builds/ to the paths known by Sprockets.
# This is where sass-embedded and tailwindcss-rails deposit their compiled files.
# Without this line, Rails would not know where to look for sass.css and tailwind.css.
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")

# Declares sass.css as an entry point to be precompiled in production.
# By default Sprockets only precompiles application.css — any additional file
# served directly to the browser must be listed explicitly here.
Rails.application.config.assets.precompile += %w[sass.css]