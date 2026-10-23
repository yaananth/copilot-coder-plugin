# Replica Hub: optional sharing destination

Use this guide only when the user selects Replica Hub and supplies an accessible
Hub. It is not a plugin dependency. Do not embed a private service URL or require a
particular Copilot host; ask for the user's destination when it is missing.

## What was observed

The user-provided Replica Hub welcome page describes repository-branch prototypes
with team review and feedback. Its publicly served client exposes separate
repository-access links and signed-out share links tied to published Builds.
This is not evidence of a standalone HTML upload endpoint.

The public client was inspected on October 23, 2026. Authentication was required
to go further, so an authenticated publish and recipient smoke test were **not**
completed during development of this guide. Treat the live UI and the Hub's
accessible documentation as authoritative if labels or capabilities change.

## Repository-backed flow

1. Open the supplied Hub and sign in using its normal GitHub flow. If sign-in,
   organization approval, or an integration installation is required, stop at that
   boundary and report what the user must complete. Do not reuse CLI tokens as
   browser sessions.
2. Read the welcome page's setup/readme links when accessible. Select the authorized
   repository and discover its actual prototype entry point, branch conventions,
   build command, and output contract. Do not guess configuration filenames or
   invent support for dropping arbitrary HTML into an unconfigured repository.
3. Prepare the artifact according to that repository's contract. Commit/push a
   prototype branch only when authorized, and only include approved browser content.
   A local HTML preview or uncommitted edit is not a published Replica Build.
4. Wait for a successful published Build. Check its commit/build identity and open
   that Build's preview. If the UI indicates the last published Build differs from
   local work, publish the intended version first or explicitly share the older
   version with the user's agreement.

## Choose access deliberately

- Prefer the repository-access prototype link for teammates who already have
  access. This requires GitHub authentication and repository access.
- Signed-out share links expose the selected published Build to anyone holding
  the link. Confirm that audience before creating one, even for a private repo.
  Never silently enable Hub-wide public sharing.
- The observed client requires public sharing to be enabled, a successful Build,
  and either repository admin access or authorship of a successful Build for the
  prototype with current read access. Write access alone may not be enough. Rely
  on the live permission check, not inferred GitHub privileges.
- In the prototype's sharing controls, verify the targeted Build, supply a short
  descriptive label, and choose the shortest suitable expiry. The observed choices
  were one day, seven days, thirty days, or no expiry; do not choose indefinite
  access by default. If unspecified and interaction is unavailable, prepare the
  share but do not create a public link.
- If sharing current control settings, verify those controls exist in the published
  Build. Settings in a copied URL do not publish local code or update a saved link.
- Copy the exact URL returned by the service. Never construct a guessed share URL.
  If a request's outcome is uncertain, refresh active links and reconcile Build,
  creator, time, and provider identity before considering a retry; a matching label
  by itself is not proof that your request succeeded.

## Recipient check and handoff

Open the generated link in a fresh signed-out context for signed-out sharing. Check
the sample heading and **Add vote** interaction (or the user's equivalent), not
just the wrapper page or an HTTP success response. Confirm the published Build
matches the intended commit and report its expiry.

If signed-out testing is unavailable, say so. If authentication, publication, or
permissions block the workflow, return the portable artifact and exact blocker,
not a fabricated live URL. Do not silently switch to public hosting elsewhere.

Explain how to find the link in the Hub's sharing controls for later revocation.
Revoking an existing link removes recipients' access; do it only when authorized.
