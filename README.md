# Frog Desk — Tidbyt

A 64×32 pixel frog desk scene with randomized character animations and a plant that grows according to actual Mount Vernon, Washington time.

## Current build status

The repository foundation is runnable now:

- exact original frog artwork is preserved from the supplied 64×32 GIF
- default blink is separated from the flower
- flower growth is time-based and independent
- ~50% default / ~50% special-selection logic is implemented
- `RIBBIT!` scheduling is tracked at roughly every 8–12 rendered cycles
- watering state is wired into the logic
- GitHub Actions render/push workflow is included

The glasses special animation is now implemented from the original frog pixels. The remaining special GIFs are still placeholders and can be replaced one-by-one without changing the main app logic.

## Files

- `frog_desk.star` — app logic
- `assets.star` — embedded binary assets used by Pixlet
- `assets/` — editable GIF/PNG source assets
- `tools/build_assets.py` — rebuilds `assets.star`
- `.github/workflows/push.yml` — optional private Tidbyt push workflow

## Local preview

```bash
cd frog-desk-tidbyt
pixlet serve frog_desk.star
```

Then open http://localhost:8080.

Or render once:

```bash
pixlet render frog_desk.star
```

## Push once to your Tidbyt

```bash
pixlet push --api-token YOUR_TOKEN --installation-id frog-desk YOUR_DEVICE_ID frog_desk.webp
```

## GitHub Actions secrets

If using the included workflow, add these repository secrets:

- `TIDBYT_API_TOKEN`
- `TIDBYT_DEVICE_ID`

The workflow currently renders and pushes every five minutes, which is GitHub Actions' normal minimum cron interval. For true per-appearance randomization, the eventual Community App version should run in Tidbyt's cloud so it is re-rendered as the device requests the app.

## Plant schedule

Current draft schedule:

- before 8 AM: sprout
- 8–10 AM: small
- 10 AM–noon: leafy
- noon–2 PM: bud
- 2–4 PM: bloom
- 4–7 PM: full bloom
- after 7 PM: wilted until watering

This is deliberately easy to tune later.
