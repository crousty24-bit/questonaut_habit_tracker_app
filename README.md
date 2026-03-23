# Questonaut

[![Version 1.1](https://img.shields.io/badge/version-1.1-2563eb)](./README.md)
[![Status MVP Completed](https://img.shields.io/badge/status-MVP%20completed-16a34a)](./README.md)
[![Rails 8](https://img.shields.io/badge/Rails-8.0-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![Hotwire](https://img.shields.io/badge/Hotwire-Turbo%20%2B%20Stimulus-f97316?logo=hotwire&logoColor=white)](https://hotwired.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-rails-06b6d4?logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)
[![SQLite](https://img.shields.io/badge/SQLite-database-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![RSpec](https://img.shields.io/badge/tests-RSpec-701516)](https://rspec.info/)
[![Devise](https://img.shields.io/badge/auth-Devise-4f46e5)](https://github.com/heartcombo/devise)

Questonaut is a gamified habit-tracking web application built with Ruby on Rails 8.

Version: `1.1`  
Status: `MVP completed`

The product turns habit building into a mission-based experience: users create habits as "missions", validate them over time, earn XP, level up, unlock badges, and review their progress from a dedicated dashboard.

## Overview

Questonaut was designed as a production-oriented MVP with a simple goal: make personal consistency easier to maintain through clear UX and lightweight gamification.

The current version includes the complete core loop:

1. Create an account
2. Access a personal dashboard
3. Create daily or weekly missions
4. Validate completed missions
5. Earn XP and levels
6. Unlock badges
7. Review progress in the statistics area

## Current Scope

Version `1.1` reflects the current implemented product, not a roadmap.

### Main features

- User authentication with Devise
- Landing page and protected personal dashboard
- Habit creation, edition, and deletion
- Daily and weekly mission frequencies
- Category-based organization for habits
- Mission validation with progress feedback
- XP and level progression
- Login streak tracking
- Badge unlocking system
- Statistics dashboard with progress insights
- Cookie consent and legal pages
- Welcome email flow with graceful failure handling when email delivery is not configured

### Gamification features

- XP is awarded through key user actions such as creating and validating missions
- User level is derived from total XP
- Login streaks are tracked automatically
- Habit streaks are calculated from completed logs
- Badge rewards cover first mission creation, streak milestones, level milestones, category milestones, and login milestones

## Product Walkthrough

### Landing page

The homepage introduces the space-themed product identity and directs users to sign up or log in.

### Authentication

Users can:

- sign up
- sign in
- edit their account
- recover their password

### Dashboard

The dashboard is the main product surface. It provides:

- current level and XP progress
- login streak and recent badges
- mission list grouped by daily and weekly habits
- category filters
- create, edit, and delete mission actions
- validation actions for completed missions
- weekly completion summary

### Statistics

The statistics area currently includes:

- success rate
- mission days
- best streak
- unlocked badges count
- weekly progress chart
- category distribution chart
- badge collection
- detailed per-mission analysis

## Core Domain Model

The current MVP is organized around the following concepts:

- `User`: authentication, XP, level, login streak, badge ownership
- `Habit`: mission definition, frequency, description, category
- `HabitLog`: completion log for a habit on a given date
- `Tag`: category attached to a habit
- `Badge`: unlockable achievement
- `UserBadge`: join model linking users and earned badges

## Tech Stack

### Backend

- Ruby
- Rails `8.0`
- SQLite
- Devise
- Solid Queue / Solid Cache / Solid Cable

### Frontend

- ERB
- Hotwire
- Turbo
- Stimulus
- Tailwind CSS
- SCSS via `sass-embedded`

### Tooling

- RSpec
- Capybara
- FactoryBot
- RuboCop
- Brakeman
- Docker
- Kamal

## Application Notes

- The app follows a server-rendered Rails architecture.
- The dashboard uses Turbo updates for a smoother create/update/validate flow.
- Styling combines Tailwind utilities with SCSS partials already structured in the codebase.
- The repository contains deployment-oriented files (`Dockerfile`, Kamal config) in addition to local development tooling.

## Local Setup

### Requirements

- Ruby compatible with the project setup
- Bundler
- SQLite

### Install

```bash
bundle install
bin/setup
```

### Start the development environment

```bash
bin/dev
```

The app will be available at `http://localhost:3000`.

### Seed the database

If you want sample data and default badges:

```bash
bin/rails db:seed
```

Seeded test users currently use:

- email pattern: `testuser1@questonaut.test` to `testuser5@questonaut.test`
- password: `password123`

## Useful Commands

```bash
bin/rails routes
bundle exec rspec
bundle exec rubocop
bin/brakeman
```

## Testing

The repository includes automated coverage for the current MVP, including:

- request specs
- model specs
- service specs
- system specs
- view specs

There are also Rails test files present in the project for selected areas.

## Project Structure

Key areas of the codebase:

- `app/models`: domain models and validations
- `app/controllers`: user flows and resource handling
- `app/services`: badge awarding logic
- `app/views`: landing page, dashboard, statistics, auth, shared UI
- `app/javascript/controllers`: Stimulus controllers
- `app/assets/stylesheets`: SCSS architecture by base, layout, components, pages, themes
- `spec`: RSpec test suite

## Legacy Project Presentation

The original French presentation-oriented README has been preserved in:

[`Project_Presentation.md`](./Project_Presentation.md)

## Team

- Théo Villalba
- Allen Koch
- William Mahi

## License

No license file is currently defined in this repository.
