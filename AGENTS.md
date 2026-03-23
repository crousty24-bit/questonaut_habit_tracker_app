# AGENTS.md

## Project
Questonaut is a Rails 8 web application built as a THP final project.
Main goal: provide a clear, usable, production-oriented MVP with simple UX, clean Rails conventions, and maintainable code.

## Core working rules
- Always prefer minimal, targeted changes over broad rewrites.
- Read related files before editing.
- Stay consistent with the existing architecture unless a change is clearly necessary.
- Do not invent requirements that are not visible in the codebase, README, issues, or prompt.
- If information is missing, state the uncertainty explicitly in the final response.
- Do not add new dependencies unless explicitly justified by the task.
- Do not expose secrets, API keys, tokens, credentials, or `.env` values.
- Keep explanations factual, concise, and technical.

## Stack assumptions
- Ruby on Rails 8
- ERB views
- RESTful routes
- Hotwire / Turbo / Stimulus when relevant
- SCSS partials compiled through the asset pipeline with sass-embedded
- Tailwind CSS via the Rails Tailwind gem
- SQLite

## Architecture rules
- Follow Rails conventions first.
- Keep controllers thin.
- Put business logic in models, POROs, or service objects only when justified.
- Prefer Rails helpers and partials over duplicated view code.
- Respect RESTful naming for routes, controllers, actions, and resources.
- Use strong params correctly.
- Avoid unnecessary abstractions.
- Do not rename files, classes, methods, or routes without a clear reason.
- Do not change database schema unless the task explicitly requires it.

## Frontend rules
- Prioritize simple UX, readability, and clear navigation.
- Reuse existing UI patterns and partials before creating new ones.
- Prefer server-rendered Rails views over unnecessary frontend complexity.
- Use Stimulus only when there is a real interaction need.
- Use Turbo Frames / Turbo Streams only when they improve UX and fit the current codebase.
- Respect the existing styling architecture before adding new classes or files.
- Prefer extending the current SCSS partials and Tailwind utility usage instead of introducing a new styling pattern.
- Do not introduce React, Vue, or a heavy JS framework.

## Styling rules
- The project uses both SCSS partials and Tailwind CSS.
- Before editing styles, inspect the existing styling approach in the relevant view, partial, and stylesheet files.
- Prefer consistency with the local pattern already used in the area being modified.
- Do not duplicate the same styling logic in both SCSS and Tailwind without a clear reason.
- Do not introduce a new CSS architecture.

## THP final project constraints
- Homepage UX must remain clear.
- Main feature must stay usable end-to-end.
- Navigation must stay simple.
- Authentication should remain simple and complete.
- Naming should remain in English for code elements.
- Code must stay clean and convention-driven.
- No API keys in clear text.
- App should remain production-oriented.
- External API integrations must be handled safely.
- Admin/dashboard logic, if touched, must remain functional and understandable.

## Questonaut domain guidance
- Main domain concepts may include habits, missions, quests, users, dashboards, progress, or gamified productivity objects.
- Preserve domain vocabulary already present in the codebase.
- Do not merge distinct concepts just because they sound similar.
- Before changing a model or route, inspect related controllers, views, forms, links, partials, and redirects.

## Rails debugging policy
- Start by identifying the exact failing user flow.
- Trace the flow from entry point to failure:
  - view or partial
  - link/button/form
  - path helper
  - HTTP verb
  - route definition
  - controller action
  - model interaction
  - redirect/render target
- Do not assume a route helper is correct without checking `config/routes.rb` or `bin/rails routes`.
- For form issues, always verify:
  - `form_with` target
  - model scope
  - URL helper
  - HTTP method
  - whether the form is for create or update
  - whether the record is persisted
- For edit/update bugs, verify that the form is scoped to the record and does not submit to the collection route by mistake.
- For `No route matches` errors, identify whether the problem is:
  - wrong path helper
  - wrong HTTP verb
  - missing member route
  - incorrect nesting
  - form/model scope mismatch
- For nested resources, always verify:
  - parent resource presence
  - nesting level in routes
  - controller expectations
  - path helper arguments and order
  - form builder scope
- Never "fix" a routing bug by replacing a correct member action with an incorrect collection action.
- Before changing routes, check whether the real issue is in the form, link, or redirect.
- When changing redirects after create/update/destroy, verify the destination route and required params.
- If Turbo is involved, verify whether the request expects:
  - full HTML response
  - Turbo Frame replacement
  - Turbo Stream response
- For Turbo-related bugs, inspect:
  - frame IDs
  - `turbo_frame_tag`
  - response format
  - whether redirects are appropriate in the current flow
  - whether a partial update is expected instead of a full-page render
- Do not remove Turbo just to hide a bug unless explicitly requested.

## Bug fixing policy
- First identify the exact failing flow.
- Reproduce the issue from the available code and error message.
- Prefer the smallest fix that restores the expected behavior.
- Do not "fix" a bug by removing a feature unless explicitly requested.
- When changing a form, verify the corresponding route helper, HTTP verb, record scope, and submit target.
- When changing nested resources, verify all generated path helpers and required parents.
- Check side effects on redirects, flash messages, and rendered partials.

## Code quality rules
- Write idiomatic Rails code.
- Avoid duplication.
- Keep methods short and readable.
- Prefer explicit names over clever code.
- Maintain consistency with existing formatting and naming.
- Add comments only when they clarify non-obvious intent.
- Do not add noisy comments.

## Testing and verification
- After code changes, run only the most relevant checks first.
- Prefer targeted verification before broad test suites.
- If the issue is about routing or forms, inspect routes and the exact helper usage first.
- If tests exist, run the tests related to the modified area.
- If linters exist, run the relevant linter on touched files when reasonable.
- If you cannot run a command, say so explicitly.
- Never claim code is verified if it was not actually run.

## Expected workflow
1. Inspect the files directly related to the task.
2. Explain the likely cause before proposing a fix.
3. Apply the smallest coherent change.
4. Verify impacted routes, forms, views, partials, redirects, and controller actions.
5. Summarize:
   - what was changed
   - why it was changed
   - what was verified
   - what remains uncertain

## Commands
- Install gems: `bundle install`
- Setup database: `bin/rails db:setup`
- Start app: `bin/dev`
- Rails console: `bin/rails console`
- Routes: `bin/rails routes`
- Run tests: `bundle exec rspec`
- Run a single spec: `bundle exec rspec path/to/spec_file.rb`
- Lint if available: `bundle exec rubocop`

## Response format
When completing a task, structure the final response with:
- Cause
- Fix
- Files changed
- Verification
- Remaining uncertainty

Do not present guesses as facts.