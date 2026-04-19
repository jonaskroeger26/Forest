# City Focus Game Balance (MVP)

## Reward Formula

- Coins: `min(120, max(10, sessionMinutes * 2 + streakDays * 2))`
- Materials: `ceil(sessionMinutes / 10) + (streakDays >= 3 ? 1 : 0)`
- Fail state: no rewards, streak decreases by 1 (not below 0)

## Unlock Progression

- Town Hall: unlocked at streak 0
- City Park: unlocked at streak 2
- Library: unlocked at streak 4
- Sky Tower: unlocked at streak 7

## Telemetry to Tune Economy

- `session_start` with duration
- `session_result` with outcome and focused seconds
- `reward_granted` with coins/materials

Use these events to tune:
- failure-to-success ratio
- average time to unlock first 3 buildings
- coins inflation per active user
