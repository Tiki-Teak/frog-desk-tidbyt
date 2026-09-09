load("render.star", "render")
load("random.star", "random")
load("time.star", "time")
load("cache.star", "cache")
load(
    "assets.star",
    "DEFAULT_BLINK",
    "FLY",
    "FRUSTRATION",
    "GLASSES",
    "RIBBIT",
    "SLEEPY",
    "WATERING",
    "STAGE_0_SPROUT",
    "STAGE_1_SMALL",
    "STAGE_2_LEAFY",
    "STAGE_3_BUD",
    "STAGE_4_BLOOM",
    "STAGE_5_FULL",
    "WILTED",
)

TIMEZONE = "America/Los_Angeles"

# One rendered file = one frog scene. When hosted as a Community App,
# Tidbyt re-renders the app and this selection can change each app appearance.
# For private testing, each pixlet render/push chooses one scene.

def _cycle_count():
    raw = cache.get("frog_cycle_count")
    count = int(raw) if raw != None else 0
    count += 1
    cache.set("frog_cycle_count", str(count), ttl_seconds = 172800)
    return count

def _next_ribbit_at(count):
    raw = cache.get("frog_next_ribbit")
    if raw != None:
        return int(raw)

    # First rare event appears 8-12 cycles from the first render.
    target = count + random.number(8, 13)
    cache.set("frog_next_ribbit", str(target), ttl_seconds = 172800)
    return target

def _choose_scene():
    count = _cycle_count()
    ribbit_at = _next_ribbit_at(count)

    if count >= ribbit_at:
        cache.set(
            "frog_next_ribbit",
            str(count + random.number(8, 13)),
            ttl_seconds = 172800,
        )
        return "ribbit"

    # Roughly half the appearances do nothing beyond the default blink.
    if random.number(0, 100) < 50:
        return "default"

    specials = ["glasses", "fly", "frustration", "sleepy", "watering"]
    return specials[random.number(0, len(specials))]

def _plant_for_time(now):
    hour = int(now.format("15"))
    minute = int(now.format("04"))
    minutes = hour * 60 + minute

    # Slow real-time growth through the day.
    if minutes < 8 * 60:
        return STAGE_0_SPROUT
    if minutes < 10 * 60:
        return STAGE_1_SMALL
    if minutes < 12 * 60:
        return STAGE_2_LEAFY
    if minutes < 14 * 60:
        return STAGE_3_BUD
    if minutes < 16 * 60:
        return STAGE_4_BLOOM
    if minutes < 19 * 60:
        return STAGE_5_FULL

    # Evening wilt. A future watering animation will set a "watered" cache
    # so later scenes can stay perked back up until the day rolls over.
    date_key = now.format("2006-01-02")
    watered = cache.get("frog_watered_" + date_key)
    if watered == "yes":
        return STAGE_5_FULL

    return WILTED

def _scene_asset(scene, now):
    if scene == "glasses":
        return GLASSES
    if scene == "fly":
        return FLY
    if scene == "frustration":
        return FRUSTRATION
    if scene == "sleepy":
        return SLEEPY
    if scene == "watering":
        # Once the final watering GIF is installed, this marks the plant
        # healthy for the remainder of the local day.
        cache.set("frog_watered_" + now.format("2006-01-02"), "yes", ttl_seconds = 43200)
        return WATERING
    if scene == "ribbit":
        return RIBBIT
    return DEFAULT_BLINK

def main(config):
    now = time.now().in_location(TIMEZONE)
    scene = _choose_scene()
    frog = _scene_asset(scene, now)

    # Watering eventually gets a self-contained animation because the plant
    # physically changes during that scene. Every other scene receives the
    # independently selected time-based plant overlay.
    if scene == "watering":
        child = render.Image(src = frog)
    else:
        child = render.Stack(children = [
            render.Image(src = frog),
            render.Image(src = _plant_for_time(now)),
        ])

    return render.Root(
        child = child,
        show_full_animation = True,
        max_age = 300,
    )
