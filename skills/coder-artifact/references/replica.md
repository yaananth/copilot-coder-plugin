# Replica Hub: customer-configured destination

Use this guide when the user selects Replica Hub or the current project's trusted
configuration identifies an authorized Hub. A publishing repository need not
already be selected or ready. Discover what exists, ask which repository to use,
and guide approved setup through to a shareable URL.
Do not supply a bundled Hub URL, organization, repository, account, or private
endpoint. Organizations operate their own Hub; this plugin supplies neither Hub
hosting nor access. Use the selected deployment's UI and version-compatible
documentation, not another customer's settings or an assumed API.

## Contents

- [Discover and offer repositories](#discover-and-offer-repositories)
- [Discover starters and templates](#discover-starters-and-templates)
- [Explain who can open the link](#explain-who-can-open-the-link)
- [Set up the selected repository](#set-up-the-selected-repository)
- [Publish and verify](#publish-and-verify)
- [Public provider documentation](#public-provider-documentation)

## Discover and offer repositories

1. Suggest the Hub found in current-project configuration or an explicitly selected
   authorized connection. If none is established, ask for the customer's Hub.
   Reuse authorized sign-in; never copy credentials or CLI tokens into a browser.
2. Read that Hub's available repositories through its supported UI or documented
   integration. Check publishing permission, connection, build configuration, and
   recent successful imported Build evidence. A picker entry or Git remote alone
   does not establish readiness. Do not crawl unrelated repository contents.
   When the user asks for other accessible repositories, use an available authorized
   GitHub connector or CLI to list repository metadata in the relevant owner scope.
   Keep Hub-visible repositories separate from GitHub-accessible candidates; check
   write permission and setup for a candidate before offering it as publish-ready.
   State pagination limits and ask for an owner only if that scope is ambiguous.
3. Present a concise list with each repository's status and reason:
   **Ready** when connection, publish permission, compatible build configuration,
   and a usable imported Build are verified; **Setup required** for known missing
   prerequisites; **Not verified** when evidence or access is unavailable.
   Distinguish a current successful baseline from an old Build or failed latest run.
   State list scope or pagination limits; do not claim an account-wide inventory.
4. Ask "Which repository should I use?" with the list, allowing a repository not
   listed. Do not choose the first entry. If the user already selected a repository,
   check it directly and continue without asking again. Absence from the picker
   or a 404 needs a connection/access check; neither proves that the repository is
   invalid or that the GitHub App lacks access.

## Discover starters and templates

When choosing or using a starter for a new prototype or requested restyle, follow
[starter and style discovery](starters.md), including access/data checks for a
starter already chosen by the user. If the look is unsettled, inspect the authorized
Hub catalog and current customer configuration, offer verified styles such as an
available GitHub starter, and ask for the choice. Do not infer employee access or
bundle a private starter with this public plugin. Publishing an existing artifact
skips this choice.

The upstream **Create** catalog uses the selected repository's retained successful
default-branch Build. `Default` opens its root; additional templates are named
routes with screenshots from that Build. These may all share one style. A missing
or unverified preview is not proof of a working starter, and a catalog selection
does not authorize copying source or publishing it.

## Explain who can open the link

Before approval and again with the result, state the actual access requirement:

- **Restricted link (default):** "Viewers must sign in to this Hub with GitHub and
  have read access to the selected repository." The Hub enforces its GitHub-backed
  access checks; this skill does not copy collaborators, grant membership, or
  change repository permissions. Confirm any additional Hub sign-in restrictions
  and the actual audience, including repository visibility. Repository read access
  can cover more people than a named review team. Do not promise immediate
  revocation or a narrower audience than the deployment enforces.
- **Signed-out link (separate opt-in):** "Anyone holding this link can view this
  Build without GitHub sign-in or repository access." Such links do not enforce
  viewer repository permissions. Check the Hub's enabled policy and the current
  user's link-management capability; repository write access alone is not proof.
  Do not enable Hub-wide public sharing implicitly. Use the main skill's approved
  expiry and recipient checks, and explain Build pinning and supported revocation.

If restricted access does not fit the intended audience, resolve that decision
before setup or publication. Do not silently make the repository or link public.
When restricted access fits, keep that default; explain the signed-out distinction
without adding an unsolicited question about switching to it.

## Set up the selected repository

1. Inspect only the selected repository's relevant configuration, default branch,
   visibility, build files, and existing publication workflow. Keep the user's
   repository permissions, the GitHub App's repository scope, and the current
   actor's ability to administer that App separate. Verify each through available
   authorized evidence; an unavailable administration page does not establish the
   App's scope. Report unknown connection/access facts as **Not verified**.
   If an authorized installation administrator is needed, ask for that person's
   connection/scope check and hand off the unavailable step. Do not offer to perform
   an App change without the capability or assume a new permission is necessary.
   Discover the actual supported build contract; do not assume arbitrary HTML
   can be uploaded or that the latest public workflow matches this deployment.
2. When setup is missing, prepare the smallest compatible change. Preserve existing
   application files, build scripts, workflows, history, and other publishing
   arrangements. For a static artifact, a small explicit-allowlist build adapter
   can be appropriate; do not replace an existing app with a starter or recursively
   package the repository. Confirm the intended artifact before preparing its files.
3. Show the observed gaps and exact proposed changes. Obtain specific approval
   for any GitHub App repository-access change, setup branch/push or installation
   PR, default-branch merge, and build/publication operation not already authorized.
   Name files, the exact branch, destination, audience, and effects. Selecting a
   repository or approving a setup PR does not authorize its merge or public sharing.
   App access covers the repository, not just the artifact allowlist; disclose that
   scope when requesting a verified necessary access change. Ask exactly one
   approval question for the next actionable operation, including the unchanged
   default audience rather than asking to choose it again. Do not bundle an
   App-admin handoff with future setup
   or publication approval. If its branch, files, build contract, or effects remain
   unknown, obtain that evidence before requesting mutation approval; a broad
   "proceed with setup and publishing" question is not a substitute. First inspect
   existing push-triggered workflows: a setup push can itself build and publish.
   If so, disclose and include those effects in this approval; do not promise
   "setup only" or defer approval for an effect the push already triggers.
   Only when the verified push cannot publish, use a setup-only question such as:
   "May I push <setup branch> with <exact files> and open its setup PR in <repo>?
   This does not merge or publish; the later restricted link will require GitHub
   sign-in and repository read access." Keep later publication pending until its
   exact branch, files, and current Build plan are known and specifically authorized.
   Keep unrelated repository access and organization-wide settings unchanged.
4. Use the selected Hub's supported installation flow. Current upstream Hub offers
   **Open installation pull request** for `.github/workflows/replica.yml`; it uses
   reserved branch `replica/install-workflow`, not a direct default-branch write.
   Inspect the generated workflow, permissions, triggers, and action pin. Keep
   custom packaging/configuration changes in a separate ordinary setup branch;
   do not repurpose the Hub's workflow-only installation branch or overwrite a
   customized workflow blindly.
5. For the standard upstream action, verify root `package.json`, `package-lock.json`,
   a nonempty build script, and `dist/index.html` after the documented build.
   Adapt only if this is the selected deployment's contract. If supported,
   `.github/replica.json` with `{"version":1,"hub":{"origin":"<selected HTTPS origin>"}}`
   enables Hub discovery from the actual default branch. It is not App installation,
   access authorization, or a replacement for the workflow. Keep the actual
   customer origin only in approved customer configuration.
6. Execute the approved steps and verify their results. For a manual sign-in,
   organization approval, or merge, name the exact remaining action and preserve
   the selected Hub/repository, pending change, and completed checks for resumption.
   Recheck current state when resumed; do not repeat completed mutations.
   After required setup is merged, verify the workflow and Hub-imported baseline.
   Hub imports successful Builds from both default and prototype branches.
   Default-branch Builds supply templates; prototype-branch Builds publish prototypes.
   Continue to the prototype publication when authorized, rather than stopping
   merely because the repository initially needed setup.

## Publish and verify

- Apply the main skill's reviewed file allowlist, local preview, new-preview
  default, and approval gate. Use a new prototype branch unless an update was
  requested. Local files and uncommitted edits are not a published Build.
- Push only what was approved. Wait for both the intended workflow's success and
  Hub import. Match repository, branch, commit, and Build identity; do not silently
  share an older Build or mistake a baseline template for the user's prototype.
- Use the exact internal prototype URL returned by the Hub for restricted sharing;
  do not create a public share link merely to obtain a shareable URL. If approved
  signed-out sharing is required, create only the scoped link after its policy,
  capability, Build, audience, and expiry have been verified.
- If sharing saved controls/settings, verify they exist in the published Build.
  A copied configuration URL does not publish local code.
- After an ambiguous mutation outcome, reconcile current setup, Build, and
  share-link state before retrying; a matching label alone is not proof of success.

Check the intended artifact and a real interaction at the returned URL. Apply the
main skill's recipient verification; the owner's session alone is insufficient.
Report the actual audience, Build identity, expiry, and any unverified step.

Use the main skill's outcome labels: verified URL, published but verification
incomplete, or **Blocked; no share URL** with one targeted unblock question.
A portable artifact is recovery material, not completion of live sharing.
Do not switch providers, fabricate a URL, or expose customer configuration publicly.

## Public provider documentation

Check compatibility with the selected Hub before applying these upstream guides:

- [Customer environment and discovery](https://github.com/github/replica/blob/main/docs/prototype-environment.md)
- [Template catalog and new-prototype handoff](https://github.com/github/replica/blob/main/hub/docs/gallery.md)
- [Adapting an existing repository](https://github.com/github/replica/blob/main/docs/prototype-repository-setup.md)
- [Workflow installation and build contract](https://github.com/github/replica/blob/main/hub/docs/github-actions-builds.md)
- [Share-link policy and permissions](https://github.com/github/replica/blob/main/hub/docs/share-links.md)
