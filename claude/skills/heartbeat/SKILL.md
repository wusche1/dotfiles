---
name: heartbeat
description: Long-running task mode. Sets a 30-min self check-in cron (jobs, hardware, costs, budget, focus, Goodharting) and runs a critique-subagent loop before declaring done.
---

You just got a long-running task. Work autonomously and keep yourself honest with a heartbeat.

## Setup (do this first)

1. Write `HEARTBEAT.md` in the working directory with: the original task verbatim, any time/money budget, the success criteria, and the intention behind the task in your own words. This survives context compaction; re-read it on every heartbeat.
2. Note the start time and which machines/instances already exist (yours vs. other people's).
3. Create a recurring cron job (CronCreate) every 30 minutes whose prompt is: "Heartbeat: re-read HEARTBEAT.md and run the heartbeat checklist from the /heartbeat skill."
4. Run anything that may take longer than a few minutes in the background (`run_in_background`, nohup, a herdr pane). The heartbeat can only wake you between turns, never during a blocking tool call.

## Delegate heavily

Whenever work can be split off or parallelized, hand it to subagents. Use them especially for anything slow (long runs, sweeps, downloads, big searches) and for babysitting jobs that need watching, so their output and polling don't fill your context. Give each subagent a self-contained brief and ask for a short result back. You stay the coordinator: track what each subagent owns and check on them in every heartbeat.

## On every heartbeat

Check:

- **Jobs:** are all background jobs, scripts and subagents still progressing? Check logs/output timestamps. Kill or restart anything stuck.
- **Hardware:** disk space, RAM, GPU memory/utilization, load on every machine you use. Is anything close to full, OOM, or crashing? Act before it fails (a pod at its memory limit can lock up SSH entirely).
- **Rented hardware & costs:** list all rented instances (Vast, RunPod, ...). Is anything idle or unnecessary? Shut down only what you started; flag others' machines, never touch them.
- **Budget:** how much time and money is used vs. the budget? Project the rest. If it won't fit, change the plan now, not at the end.
- **Focus:** compare what you are doing to the original task. Is this helping, or a tangent?
- **Goodharting:** if optimizing a metric, are you gaming it rather than serving the intention behind it? Spot-check actual outputs, not just the number.

If everything is fine, carry on.

## When you think you are done

1. Write the final report (results, evidence, how to reproduce).
2. Launch critique subagents in parallel. Give each one the original task verbatim, the report path, and access to the repo, results and artifacts, but not your own assessment of how it went. Lenses:
   - **Clarity:** is the report understandable to someone who didn't do the work?
   - **Rigor:** does the evidence conclusively show what the report claims? Overclaims, missing baselines, confounds, too few seeds?
   - **Next steps:** what other experiments or settings should be run? Was the intention of the task served, or just the metric?
3. Run the worthwhile suggested experiments, revise the report, and repeat the critique, up to 3 rounds or until the critiques only raise minor points.
4. Shut down the instances you started (unless results still need them), delete the heartbeat cron (CronDelete), and finish with a summary of what was done, what it cost, and what remains open.
