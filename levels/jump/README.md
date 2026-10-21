# Jump — JUMP

Space starts/restarts the runner and jumps while running. Holding Space jumps
again on landing, as in the source. Escape returns to Matrix. Close the window
to quit the application.

Preserved: 800×400 logical field; original sky, ground, stand/walk/jump/snail/fly
art and Pixeltype font; 64×84 player hitbox at (48,216); gravity +1 and jump -25;
walk/fly/snail animation increments; fly speed 5 and snail speed 3; 1.6-second
spawn timer that continues through intros; weighted 1:3 fly/snail selection and
900–1100 spawn centers; rectangle collision loss, cleared obstacles, reset,
survival score and final-score intro; looping music and quarter-volume jump SFX.
The jump artwork is wider than the source's unchanged collision rectangle.

Assets copied from `legacy/pygame/levels/jump/`, without new attribution or
ownership claims. Runtime uses only this module's Godot resources. Audio/timer
nodes belong to the level root and are freed on return.

Differences: original capped frame updates now run at fixed 60 physics ticks/sec;
the logical field fits the shared resizable window; Escape and a return hint are
new. Godot's font metrics, texture filtering and audio loop boundaries may differ.
The score retains floor-to-seconds reset behavior, with Godot's monotonic clock.

Checks cover initial intro/music playback state, reset, jump/landing, obstacle
sizes/speeds, timer spawning, collision loss, and audio-node cleanup. Headless
checks verify stream state, not audible playback. Manual sustained jumping,
obstacle timing, scoring, music/SFX and cross-platform playtests remain needed.
