# Discover starter and style choices

Use this guide when choosing or using a starter for a new prototype or an explicitly
requested restyle. A named starter still needs access, permitted-use, and data-mode
checks; only the choice question is conditional on the look being unsettled.
A starter supplies application code, components, styles, and sometimes data
integration; the publisher does not supply those merely by hosting an artifact.

For an existing-artifact sharing request, preserve its styling and skip this
choice, even when other starters are available. Do not turn publishing into a
redesign or replace the user's artifact with a starter.

## Discover the current customer's options

- Read relevant project instructions, starter/template configuration, package
  manifests, and component/theme entry points. Use the selected Hub's authorized
  template catalog and starter repositories explicitly configured for this
  customer, including repositories exposed by that Hub's inventory when relevant.
  Inspect scoped metadata first; do not clone or crawl every accessible repository.
- Establish access to a candidate before offering it as available. Do not infer
  employment or entitlement from an email address, username, repository owner,
  browser tab, or a remembered configuration from another customer.
- Verify the claimed design system from current source/configuration and a preview
  when available; a repository name alone is insufficient. If an accessible starter
  uses GitHub styling, offer **GitHub look** by name without hardcoding its private
  source in this skill. Apply the same discovery to another customer's branding.
- For each useful option, record its source repository/ref or retained Build,
  starter name, design system, available preview, and data mode: **sample data**,
  **live integration**, or **unverified**. Bound data claims to what was inspected;
  a seeded page does not prove every route is offline. Never connect a database,
  supply credentials, or call a live mutation just to classify a starter.
- Use actual available screenshots or preview links. If a preview cannot be
  checked, say so instead of inventing one. Keep private source/preview details in
  the current authorized task, not public documentation or a cross-customer catalog.

For Replica, discover the selected deployment's template catalog through its
supported UI or documented integration. Current upstream catalogs describe routes
and screenshots from a retained default-branch Build; several routes can belong
to the same application and style. A template route is not necessarily a separate
starter repository or design system. Record the Build/reference used for discovery,
and distinguish it from the branch head used to start new work.

## Ask for the look once

Show a concise set of verified choices with their style, source, preview status,
and data mode, then ask one question: **Which starter or look should I use?**
For example, a verified GitHub-style starter can appear alongside the customer's
other available starters and **Custom look**.

Custom look is a request for new design work, not a claim that a ready-made custom
starter exists. If no usable starter is discovered, state that limitation and ask
for an approved starter source or a custom direction. A requested but inaccessible
starter is not permission to fetch private material elsewhere or silently choose
another brand. Do not offer a missing GitHub starter just because it was available
to a previous customer.

Honor a choice already supplied by the user or clearly established by the task;
do not ask it again. Keep repository, starter/style, and publication decisions
distinct, asking only the next unresolved decision rather than a questionnaire.

## Continue with the selected starter

- Retain the selected source/ref or template route, target repository, style, and
  data mode with the task so resumption does not switch starters silently.
- Reuse the selected application's existing components and build conventions.
  Inspect required assets and dependencies before running setup. Do not replace
  an existing site's root, workflows, or data integrations as an implicit import.
- Repository read access is not permission to redistribute private starter code.
  Before cross-repository copying or publication, verify the source's permitted
  use and target audience, and apply the main skill's exact-file and external-action
  approval gates. A style choice does not authorize app installation, public
  disclosure, backend provisioning, or publication.
- Preserve the declared data mode. Any new live backend, credentials, or external
  side effects need their own scoped authorization; never present mock behavior
  as a working production integration.

Continue through the main skill's preparation, preview, publishing, and recipient
checks. Choosing a starter is not a completed artifact or share.
